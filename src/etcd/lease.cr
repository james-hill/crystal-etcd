require "./model/lease"

module Etcd
  class Lease 
    getter stub : Etcdserverpb::Lease::Stub

    def initialize(@api : Etcd::Api)
      @stub = Etcdserverpb::Lease::Stub.new(@api.config)
    end

    # /kv/lease/leases
    # /lease/leases
    # Queries for all existing leases in an etcd cluster
    def leases
      (stub.lease_leases(Etcdserverpb::LeaseLeasesRequest.new).leases || [] of Etcdserverpb::LeaseStatus).map do |lease|
        lease.id
      end
    end

    # /kv/lease/revoke
    # Revokes an etcd lease
    # id  Id of lease  Int64
    def revoke(id : Int64)
      stub.lease_revoke(Etcdserverpb::LeaseRevokeRequest.new(id: id)).is_a?(Etcdserverpb::LeaseRevokeResponse)
    end

    # /kv/lease/timetolive
    # /lease/timetolive
    # Queries the TTL of a lease
    # id            id of lease                         Int64
    # query_keys    query all the lease's keys for ttl  Bool
    def timetolive(id : Int64, query_keys = false)
      Model::TimeToLive.from_grpc(
        stub.lease_time_to_live(Etcdserverpb::LeaseTimeToLiveRequest.new(id: id, keys: query_keys))
      )
    end

    # /lease/grant
    # Requests a lease
    # ttl   ttl of granted lease                            Int64
    # id    id of 0 prompts etcd to assign any id to lease  UInt64
    def grant(ttl : Int64 = @ttl, id = 0)
      Model::Grant.from_grpc(
      stub.lease_grant(Etcdserverpb::LeaseGrantRequest.new(ttl: ttl, id: id))
      )    
    end

    # /lease/keepalive
    # Requests persistence of lease.
    # Must be invoked periodically to avoid key loss.
    def keep_alive(id : Int64) : Int64?
      stub.lease_keep_alive(Etcdserverpb::LeaseKeepAliveRequest.new(id: id)).ttl
    end
  end
end
