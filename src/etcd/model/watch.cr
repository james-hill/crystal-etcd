require "./base"
require "./kv"

module Etcd::Model
  struct WatchError 
    getter http_code : Int32

    def initialize(@http_code : Int32)
    end  
  end

  struct WatchEvent 
    enum Type
      PUT
      DELETE

      # Note: for some reason etcd seems to return nil for PUT but the correct type for DELETE?!
      def self.from_grpc(grpc_type : Mvccpb::Event::EventType?)
        case grpc_type
        when Mvccpb::Event::EventType::DELETE
          Etcd::Model::WatchEvent::Type::DELETE
        else
          Etcd::Model::WatchEvent::Type::PUT
        end        
      end     
    end

    # Empty type field indicates PUT event
    getter type : WatchEvent::Type? = WatchEvent::Type::PUT
    getter! kv : Kv

    def self.from_grpc(grpc_event : Mvccpb::Event)      
      if kv = grpc_event.kv
        self.new(
          type: WatchEvent::Type.from_grpc(grpc_event.type),
          kv: Kv.from_grpc(kv)
        )
      else
        raise "Event without kv: #{grpc_event.inspect}"
      end      
    end

    def initialize(@type = WatchEvent::Type::PUT, @kv : Kv? = nil)
    end
  end
end
