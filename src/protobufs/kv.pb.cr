## Generated from kv.proto for mvccpb
require "protobuf"

module Mvccpb
  
  struct KeyValue
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :key, :bytes, 1
      optional :create_revision, :int64, 2
      optional :mod_revision, :int64, 3
      optional :version, :int64, 4
      optional :value, :bytes, 5
      optional :lease, :int64, 6
    end
  end
  
  struct Event
    include ::Protobuf::Message
    enum EventType
      PUT = 0
      DELETE = 1
    end
    
    contract_of "proto3" do
      optional :type, Event::EventType, 1
      optional :kv, KeyValue, 2
      optional :prev_kv, KeyValue, 3
    end
  end
  end
