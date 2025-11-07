module Etcd::Model
  struct Lease
    getter! id : Int64

    def self.from_grpc(lease : Etcdserverpb::LeaseStatus)
      self.new(lease.id)      
    end

    def initialize(@id : Int64)
    end
  end

  struct TimeToLive
    getter! id : Int64
    getter! ttl : Int64
    getter! granted_ttl : Int64
    getter! keys : Array(String)? # This should be Array(Bytes)?

    def self.from_grpc(lease : Etcdserverpb::LeaseTimeToLiveResponse)
      keys = [] of String
      if raw_keys = lease.keys
        keys = raw_keys.map do |key|
          String.new(key)
        end
      end
      self.new(lease.id, lease.ttl, lease.granted_ttl, keys)
    end

    def initialize(@id : Int64?, @ttl : Int64?, @granted_ttl : Int64?, @keys : Array(String)?)
    end  
  end

  # Returns error
  struct Grant
    getter! id : Int64
    getter! ttl : Int64

    def initialize(@id : Int64?, @ttl : Int64?)
    end

    def self.from_grpc(lease : Etcdserverpb::LeaseGrantResponse)
      self.new(lease.id, lease.ttl)
    end  
  end
end
