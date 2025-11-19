require "./client"
require "./model/watch"
require "./utils"

class Etcd::Watch
  include Utils

  RECONNECT_SECONDS = 5

  # Types for watch event filters
  enum Filter
    NOPUT    # filter put events
    NODELETE # filter delete events

    def to_grpc
      case self
      when .noput?
        Etcdserverpb::WatchCreateRequest::FilterType::NOPUT
      when .nodelete?
        Etcdserverpb::WatchCreateRequest::FilterType::NODELETE
      end
    end
  end

  getter stub : Etcdserverpb::KV::Stub
  @config : GRPC::Config

  def initialize(@config : GRPC::Config)
    @stub = Etcdserverpb::KV::Stub.new(@config)
  end


  # Watches keys by prefix, passing events to a supplied block.
  # Exposes a synchronous interface to the watch session via `Etcd::Watcher`
  #
  # *Options*
  #  - `filters`
  #    filters filter the events at server side before it sends back to the watcher.
  #  - `start_revision`
  #    start_revision is an optional revision to watch from (inclusive). No start_revision is "now".
  #  - `progress_notify`
  #    progress_notify is set so that the etcd server will periodically send a WatchResponse with no events to the new watcher
  #    if there are no recent events. It is useful when clients wish to recover a disconnected watcher starting from
  #    a recent known revision. The etcd server may decide how often it will send notifications based on current load.
  #  - `prev_kv`
  #    If prev_kv is set, created watcher gets the previous Kv before the event happens.
  def watch_prefix(prefix, **opts, &block : Array(Model::WatchEvent) -> Void)
    opts = opts.merge({range_end: prefix_range_end(prefix), base64_keys: false})
    watch(prefix, **opts, &block)
  end

  # Watch a key in ETCD, returns a `Etcd::Watcher`
  # NOTE: base64_keys is deprecated and does nothing!
  # Exposes a synchronous interface to the watch session via `Etcd::Watcher`
  #
  # *Options*
  #  - `range_end`
  #    range_end is the end of the range [key, range_end) to watch.
  #  - `filters`
  #    filter the events at server side before it sends back to the watcher.
  #  - `start_revision`
  #    start_revision is an optional revision to watch from (inclusive). No start_revision is "now".
  #  - `progress_notify`
  #    progress_notify is set so that the etcd server will periodically send a WatchResponse with no events to the new watcher
  #    if there are no recent events. It is useful when clients wish to recover a disconnected watcher starting from
  #    a recent known revision. The etcd server may decide how often it will send notifications based on current load.
  #  - `prev_kv`
  #     If prev_kv is set, created watcher gets the previous Kv before the event happens.
  def watch(
    key,
    range_end : String | Slice(UInt8)? = nil,
    filters : Array(Watch::Filter)? = nil,
    start_revision : Int64? = nil,
    progress_notify : Bool? = nil,
    base64_keys : Bool = true,
    &block : Array(Model::WatchEvent) -> Void
  ) : Watcher
    Watcher.new(
      key: key,
      config: @config,
      range_end: range_end,
      filters: filters,
      start_revision: start_revision,
      progress_notify: progress_notify,
      &block
    )
  end

  # Wrapper for a watch session with etcd.
  #
  # ```
  # client = Etcd::Client.new
  # watcher = client.watch(key: "hello") do |e|
  #   # This block will be called upon each etcd event
  #   puts e
  # end
  #
  # spawn { watcher.start }
  # ```
  class Watcher
    Log = ::Log.for(self)

    getter key : String
    private getter config : GRPC::Config
    private getter block : Proc(Array(Model::WatchEvent), Void)
    private getter range_end : String?
    private getter filters : Array(Watch::Filter)?
    private getter start_revision : Int64?
    private getter progress_notify : Bool?

    private property event_channel : Channel(Array(Model::WatchEvent)) { Channel(Array(Model::WatchEvent)).new }

    getter? watching : Bool = false
    getter watch_id : Int64? = nil
    getter stream_id : Int32? = nil

    getter stub : Etcdserverpb::Watch::Stub

    def initialize(
      @key,
      @config = GRPC::Config,
      range_end = nil,
      @filters = nil,
      @start_revision = nil,
      @progress_notify = nil,
      &@block : Array(Model::WatchEvent) -> Void
    )
      @stub = Etcdserverpb::Watch::Stub.new(@config)

      @range_end = case range_end
      when String
        range_end
      when Slice(UInt8)
        String.new(range_end)
      else
        nil
      end
    end

    # Pass events to captured block
    private def forward_events
      self.event_channel = Channel(Array(Model::WatchEvent)).new if self.event_channel.closed?
      while event = self.event_channel.receive?
        # Don't forward empty events
        @block.call(event) unless event.empty?
      end
    end

    # Start the watcher
    def start
      raise Etcd::WatchError.new "Already watching `#{key}`" if watching?
      Log.context.set({key: key, range_end: range_end})

      spawn { forward_events }

      filters = @filters.try(&.map(&.to_grpc)).try(&.compact)

      request = Etcdserverpb::WatchRequest.new(
        create_request: Etcdserverpb::WatchCreateRequest.new(
          key: key.to_slice,
          range_end: range_end.try(&.to_slice),
          filters: filters,
          start_revision: start_revision,
          progress_notify: progress_notify,            
        )
      )

      @watching = true      

      while watching?
        begin
          headers = HTTP::Headers{
            ":method" => "POST",
            ":path" => "/etcdserverpb.Watch/Watch",
            "content-type" => "application/grpc",  
          }
          data = GRPC.encode_protobuf(request)
          
          # This will yield each time there's a data frame
          if http2 = @config.http2
            channel = http2.open_stream(headers, data: data)
            
            while payload = channel.receive?
              payload = IO::Memory.new(payload)
              if payload.size > 0
                response = GRPC.decode_protobuf(payload, Etcdserverpb::WatchResponse)
                
                # Very first data frame contains the watch ID
                unless @watch_id
                  @watch_id = response.watch_id
                end

                if raw_events = response.events
                  events = raw_events.map{|grpc_event| Model::WatchEvent.from_grpc(grpc_event)}.compact                
                  unless events.empty? || self.event_channel.closed?
                    self.event_channel.send(events) 
                  end
                end
              end
            end
          else
            raise "No http2 object (this should never happen)"
          end          
          
        rescue e
          Log.warn {"Watcher error #{e.inspect_with_backtrace} sleeping and reconnecting"}
          sleep Time::Span.new(seconds: RECONNECT_SECONDS)
        end
      end
    end

    # Close the client and stop the watcher
    def stop
      @watching = false
      self.event_channel.close      
    end
  end
end
