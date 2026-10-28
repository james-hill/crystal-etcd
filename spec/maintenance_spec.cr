require "./helper"

module Etcd
  describe Maintenance do
    it "queries status of cluster" do
      client = Etcd.from_env

      status = client.maintenance.status
      status.should_not be_nil
      status.leader.should be_a UInt64
      status.version.should be_a String
      status.db_size.should be > 0
      status.errors.should be_empty
      status.is_learner.should be_false
    end

    it "queries leader" do
      client = Etcd.from_env

      leader = client.maintenance.leader
      leader.should be_a UInt64
    end

    it "hashes the backend" do
      client = Etcd.from_env

      client.maintenance.hash.should be_a UInt32
    end

    it "hashes the key-value state at a revision" do
      client = Etcd.from_env
      key = "#{TEST_PREFIX}/hash"
      client.kv.put(key, "one")
      revision = client.kv.range(key).kvs.first.mod_revision.not_nil!
      at_revision = client.maintenance.hash_kv(revision)
      client.kv.put(key, "two")

      client.maintenance.hash_kv(revision).hash.should eq at_revision.hash
      client.maintenance.hash_kv.hash.should_not eq at_revision.hash
    end

    it "streams a snapshot" do
      client = Etcd.from_env
      client.kv.put("#{TEST_PREFIX}/snapshot", "x" * 1024)

      io = IO::Memory.new
      written = client.maintenance.snapshot(io)

      written.should eq io.size
      written.should be > 0
      # A bbolt database file, followed by etcd's 512-byte integrity hash
      written.should be > 512
      io.to_slice[16, 4].should eq Bytes[0xED, 0xDA, 0x0C, 0xED]
    end

    it "transfers leadership" do
      client = Etcd.from_env

      # A single member has nobody to hand over to: moving to itself is a no-op and an
      # unknown member is refused, which together show the target id reaches etcd intact
      client.maintenance.transfer_leadership(client.maintenance.leader).should be_true

      expect_raises(GRPC::BadStatus) do
        client.maintenance.transfer_leadership(1_u64)
      end
    end
  end
end
