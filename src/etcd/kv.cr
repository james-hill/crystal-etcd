require "./model/kv"
require "./utils"

module Etcd
  class Kv
    include Etcd::Utils

    getter stub : Etcdserverpb::KV::Stub

    def initialize(@config : GRPC::Config)
      @stub = Etcdserverpb::KV::Stub.new(@config)
    end

    # Sets a key and value in etcd.
    # key             key is the string that will be base64 encoded and associated with value in the kv store                          String
    # value           value is the string that will be base64 encoded and associated with key in the kv store                          String
    # opts
    #   lease         lease is the lease ID to associate with the key in the key-value store. A lease value of 0 indicates no lease.   Int64
    #   prev_kv       If prev_kv is set, etcd gets the previous key-value pair before changing it.
    #                 The previous key-value pair will be returned in the put response.                                                 Bool
    #   ignore_value  If ignore_value is set, etcd updates the key using its current value. Returns an error if the key does not exist  Bool
    #   ignore_lease  If ignore_lease is set, etcd updates the key using its current lease. Returns an error if the key does not exist  Bool
    def put(
      key : String,
      value,
      lease : Int64 = 0_i64,
      prev_kv : Bool? = nil,
      ignore_value : Bool? = nil,
      ignore_lease : Bool? = nil,
    )
      response = stub.put(
        Etcdserverpb::PutRequest.new(
          key: key.to_slice,
          value: value.to_slice,
          lease: lease,
          prev_kv: prev_kv,
          ignore_value: ignore_value,
          ignore_lease: ignore_lease,
        )
      )

      Model::Put.from_grpc(response)
    end

    # Deletes key or range of keys
    # Note: base64_keys is deprected now that we use gRPC
    def delete(key, range_end : Slice(UInt8)? = nil, base64_keys : Bool = true, prev_kv = false )
      request = Etcdserverpb::DeleteRangeRequest.new(
        key: key.to_slice,
        range_end: range_end,
        prev_kv: prev_kv,
      )
      
      Model::Delete.from_grpc(stub.delete_range(request))
    end

    # Deletes an entire keyspace prefix
    def delete_prefix(prefix, prev_kv = false)
      range_end = prefix_range_end prefix
      delete(prefix, range_end, prev_kv: prev_kv)
    end

    # Queries a range of keys
    # Note: base64_keys is deprected now that we use gRPC
    def range(key, range_end : Slice(UInt8)? = nil, limit : Int64 = 0_i64, base64_keys : Bool = true)
      request = Etcdserverpb::RangeRequest.new(
        key: key.to_slice,
        range_end: range_end,
        limit: limit,
      )
      Model::Range.from_grpc(stub.range(request))
    end

    # Range that automatically yields each Etcd::Model::Kv
    def range(key, range_end : Slice(UInt8)? = nil, limit : Int64 = 0_i64, &block)
      range(key, range_end, limit).kvs.each do |kv|
        yield kv
      end
    end

    # Query keys beneath a prefix
    def range_prefix(prefix, limit : Int64 = 0_i64)
      range_end = prefix_range_end prefix
      range(prefix, range_end, limit)
    end

    # Query all keys >= key
    def range_greater_than_or_equal(key)
      range_end = "\0".to_slice
      range(key, range_end: range_end)
    end

    def txn(compare : Array(Etcdserverpb::Compare), success : Array(Etcdserverpb::RequestOp), failure = [] of Etcdserverpb::RequestOp)
      response = stub.txn(Etcdserverpb::TxnRequest.new(compare, success, failure))
      Model::Txn.from_grpc(response).succeeded
    end

    def compaction(physical : Bool, revision : Int64)
      stub.compaction(Etcdserverpb::CompactionRequest.new(physical:  physical, revision: revision)).is_a?(Etcdserverpb::CompactionResponse)
    end

    # Non-Standard Requests
    ##############################################################################

    # Sets a key if the key is not already present.
    #
    # Wrapper over the etcd transaction API.
    def put_not_exists(key : String, value, lease : Int64 = 0_i64) : Bool
      compare = [
        Etcdserverpb::Compare.new(
          key: key.to_slice,
          value: "0".to_slice,
          target: Etcdserverpb::Compare::CompareTarget::VERSION,
          result: Etcdserverpb::Compare::CompareResult::EQUAL,       
        )
      ]

      success = [
        Etcdserverpb::RequestOp.new(
          request_put: Etcdserverpb::PutRequest.new(
            key: key.to_slice,
            value: value.to_slice,
            lease: lease,
            ignore_lease: false,
          )
        )         
      ]

      txn(compare, success)
    end

    # Moves a value from `key` to `key_destination`, deleting the kv at `key` in the process.
    def move(key : String, key_destination : String, lease : Int64 = 0_i64) : Bool
      key_o = key.to_slice
      key_d = key_destination.to_slice
      if value = get(key)
        compare = [
          Etcdserverpb::Compare.new(
            key: key_d,
            value: "0".to_slice,
            target: Etcdserverpb::Compare::CompareTarget::VERSION,
            result: Etcdserverpb::Compare::CompareResult::EQUAL,       
          ),
          Etcdserverpb::Compare.new(
            key: key_o,
            value: "0".to_slice,
            target: Etcdserverpb::Compare::CompareTarget::VERSION,
            result: Etcdserverpb::Compare::CompareResult::NOT_EQUAL,       
          ),      
        ]

        success = [
          Etcdserverpb::RequestOp.new(
            request_put: Etcdserverpb::PutRequest.new(
              key: key_d,
              value: value.to_slice,
              lease: lease,
              ignore_lease: false,
            )
          ),
          Etcdserverpb::RequestOp.new(
            request_delete_range: Etcdserverpb::DeleteRangeRequest.new(
              key: key_o,
            )
          ),
        ]

        txn(compare, success)
      else
        false
      end
    end

    # Sets a `key` if the given `previous_value` matches the existing value for `key`
    #
    # Wrapper over the etcd transaction API.
    def compare_and_swap(key, value, previous_value, lease_id : Int64 = 0_i64) : Bool
      encoded_key = key.to_slice
      encoded_value = value.to_slice
      encoded_previous_value = previous_value.to_slice
      
      compare = [
        Etcdserverpb::Compare.new(
          key: encoded_key,
          value: encoded_previous_value,
          target: Etcdserverpb::Compare::CompareTarget::VALUE,
          result: Etcdserverpb::Compare::CompareResult::EQUAL,       
        )
      ]

      success = [
        Etcdserverpb::RequestOp.new(
          request_put: Etcdserverpb::PutRequest.new(
            key: encoded_key,
            value: encoded_value,
            lease: lease_id,
          )
        )         
      ]

      txn(compare, success)
    end

    def get(key) : String?
      range(key).kvs.first?.try(&.value)
    end
  end
end
