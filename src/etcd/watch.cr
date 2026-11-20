require "./client"
require "./model/watch"
require "./message_buffer"
require "./utils"

class Etcd::Watch
  include Utils

  RECONNECT_SECONDS     =  1
  RECONNECT_MAX_SECONDS = 30

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

  def initialize(@api : Etcd::Api)
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
      api: @api,
      range_end: range_end,
      filters: filters,
      start_revision: start_revision,
      progress_notify: progress_notify,
      &block
    )
  end

  alias MessageBuffer = Etcd::MessageBuffer(Etcdserverpb::WatchResponse)

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
    getter api : Etcd::Api
    private getter block : Proc(Array(Model::WatchEvent), Void)
    private getter range_end : String?
    private getter filters : Array(Watch::Filter)?
    private getter progress_notify : Bool?

    # Advances with every response so a reconnect resumes where the stream dropped
    getter start_revision : Int64?

    private property event_channel : Channel(Array(Model::WatchEvent)) { Channel(Array(Model::WatchEvent)).new }

    getter? watching : Bool = false
    getter watch_id : Int64? = nil
    getter stream_id : Int32? = nil

    # Header revision of the latest response that carried no events, such as a progress reply
    getter progress_revision : Int64? = nil

    @stream : GRPC::Client::OpenStream? = nil

    def initialize(
      @key,
      @api = Etcd::Api,
      range_end = nil,
      @filters = nil,
      @start_revision = nil,
      @progress_notify = nil,
      &@block : Array(Model::WatchEvent) -> Void
    )
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
        next if event.empty?

        begin
          @block.call(event)
        rescue error
          Log.error(exception: error) { "Watch subscriber raised; later events will still be delivered" }
        end
      end
    end

    private def watch_request : Etcdserverpb::WatchRequest
      filters = @filters.try(&.map(&.to_grpc)).try(&.compact)

      Etcdserverpb::WatchRequest.new(
        create_request: Etcdserverpb::WatchCreateRequest.new(
          key: key.to_slice,
          range_end: range_end.try(&.to_slice),
          filters: filters,
          start_revision: start_revision,
          progress_notify: progress_notify,
        )
      )
    end

    # Reads payloads until the stream closes, handing each complete message to `handle_response`
    private def consume(channel : Channel(Bytes), &) : Nil
      messages = MessageBuffer.new

      while payload = channel.receive?
        messages << payload
        while response = messages.next_message
          yield response
        end
      end
    end

    # Returns false when etcd cancelled the watch and the stream must be re-created
    private def handle_response(response : Etcdserverpb::WatchResponse) : Bool
      # Very first data frame contains the watch ID
      @watch_id ||= response.watch_id

      if response.canceled
        if (compacted = response.compact_revision) && compacted > 0
          Log.warn { "Watch resumed past a compaction: revision #{start_revision} is gone, continuing from #{compacted + 1}; re-list to catch up" }
          @start_revision = compacted + 1
        else
          Log.warn { "Watch cancelled by etcd: #{response.cancel_reason}" }
        end
        return false
      end

      # The creation ack carries the current revision, which would skip a replay from an older start_revision
      if !response.created && (header = response.header) && (revision = header.revision) && revision > 0
        @start_revision = revision + 1
      end

      raw_events = response.events
      if !response.created && (raw_events.nil? || raw_events.empty?)
        @progress_revision = response.header.try(&.revision)
      end

      if raw_events
        events = raw_events.map { |grpc_event| Model::WatchEvent.from_grpc(grpc_event) }.compact
        unless events.empty? || self.event_channel.closed?
          self.event_channel.send(events)
        end
      end

      true
    end

    # Start the watcher
    def start
      raise Etcd::WatchError.new "Already watching `#{key}`" if watching?
      Log.context.set({key: key, range_end: range_end})

      spawn { forward_events }

      @watching = true
      reconnect_seconds = RECONNECT_SECONDS

      while watching?
        begin
          headers = HTTP::Headers{
            ":method"      => "POST",
            ":path"        => "/etcdserverpb.Watch/Watch",
            "content-type" => "application/grpc",
          }
          data = GRPC.encode_protobuf(watch_request)

          # Reset watch_id so we capture the new one after reconnection
          @watch_id = nil

          @api.max_retries = 0
          if (http2 = @api.config.http2) && !http2.connection.closed?
            stream = @stream = http2.open_stream(headers, data: data)

            consume(stream.receive) do |response|
              # Anything from etcd means the connection is healthy again
              reconnect_seconds = RECONNECT_SECONDS
              break unless handle_response(response)
            end

            Log.warn { "Watcher stream closed, sleeping and reconnecting" }
          else
            raise "No connected http2 object... sleeping and reconnecting"
          end
        rescue error
          Log.warn(exception: error) { "Watcher error while sleeping and reconnecting" }
        end

        break unless watching?

        sleep Time::Span.new(seconds: reconnect_seconds)
        reconnect_seconds = Math.min(reconnect_seconds * 2, RECONNECT_MAX_SECONDS)

        begin
          @api.reconnect
        rescue error
          Log.warn(exception: error) { "Watcher error during reconnection" }
        end
      end
    end

    # Asks etcd for a progress reply: an empty response whose header revision is the store's
    # current revision, read from `progress_revision` once it arrives
    def request_progress : Nil
      send_request(Etcdserverpb::WatchRequest.new(progress_request: Etcdserverpb::WatchProgressRequest.new))
    end

    # Tells etcd to cancel the watch, then stops the watcher
    def cancel : Nil
      # etcd numbers a stream's watches from 0 and the creation ack omits a zero id
      send_request(Etcdserverpb::WatchRequest.new(cancel_request: Etcdserverpb::WatchCancelRequest.new(watch_id: watch_id || 0_i64)))
    ensure
      stop
    end

    private def send_request(request : Etcdserverpb::WatchRequest) : Nil
      stream = @stream
      raise Etcd::WatchError.new("No open watch stream for `#{key}`") if stream.nil? || stream.closed?
      stream.send(GRPC.encode_protobuf(request))
    end

    # Close the client and stop the watcher
    def stop
      @watching = false
      self.event_channel.close
      # ends `start` now instead of at the next frame
      @stream.try(&.close)
    end
  end
end
