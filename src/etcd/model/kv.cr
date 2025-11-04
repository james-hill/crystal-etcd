require "./base"

module Etcd::Model
  struct Kv 
    getter create_revision : Int64?
    getter key : String
    getter lease : Int64?
    getter mod_revision : Int64?
    getter value : String?
    getter version : Int64?

    def self.from_grpc(kv : Mvccpb::KeyValue)
      value = case raw_value = kv.value
        when Slice(UInt8)
          String.new(raw_value)
        else
          nil
        end

      self.new(
        create_revision: kv.create_revision,
        key: String.new(kv.key || raise "Key is nil"),
        lease: kv.lease,
        mod_revision: kv.mod_revision,
        value: value,
        version: kv.version
      )
    end  

    def initialize(@create_revision : Int64?, @key : String, @lease : Int64?, @mod_revision : Int64?, @value : String?, @version : Int64?)
    end
  end

  struct Range 
    getter count : Int64 = 0
    getter kvs : Array(Etcd::Model::Kv) = [] of Etcd::Model::Kv
    getter more : Bool = false

    def self.from_grpc(range_response : Etcdserverpb::RangeResponse)
      self.new(
        count: range_response.count || 0_i64,
        kvs: (range_response.kvs || [] of Mvccpb::KeyValue).map { |kv| Etcd::Model::Kv.from_grpc(kv) },
        more: range_response.more || false,
      )
    end

    def initialize(@count : Int64, @kvs : Array(Etcd::Model::Kv), @more : Bool)
    end
  end
  
  struct Put 
    getter prev_kv : Kv?

    def self.from_grpc(put_response : Etcdserverpb::PutResponse)
      if prev_kv = put_response.prev_kv
        self.new(
          prev_kv: Etcd::Model::Kv.from_grpc(prev_kv)
        )
      else
        nil
      end
    end  

    def initialize(@prev_kv : Kv?)
    end
  end

  struct Delete
    getter deleted : Int64 = 0
    getter prev_kvs : Array(Etcd::Model::Kv) = [] of Etcd::Model::Kv

    def self.from_grpc(delete_response : Etcdserverpb::DeleteRangeResponse)
      self.new(
        deleted: delete_response.deleted || 0_i64,
        prev_kvs: (delete_response.prev_kvs || [] of Mvccpb::KeyValue).map { |kv| Etcd::Model::Kv.from_grpc(kv) }
      )      
    end  

    def initialize(@deleted : Int64, @prev_kvs : Array(Etcd::Model::Kv))
    end
  end

  struct TxnResponse
    getter response_range : Range?
    getter response_put : Put?
    getter response_delete : Delete?
  end

  struct Txn
    getter succeeded : Bool = false
    getter responses : Array(TxnResponse) = [] of TxnResponse
  end
end
