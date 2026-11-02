require "./helper"

module Etcd
  describe Cluster do
    it "lists the members" do
      client = Etcd.from_env

      members = client.cluster.member_list
      members.size.should eq 1
      members.first.name.should_not be_empty
      members.first.client_urls.should_not be_empty
    end

    it "adds and removes a learner" do
      client = Etcd.from_env

      added = client.cluster.member_add(true, ["http://127.0.0.1:12380"])
      begin
        added.member.is_learner?.should be_true
        # a member that never started has no name yet
        added.member.name?.to_s.should be_empty
        added.member.peer_urls.should eq ["http://127.0.0.1:12380"]
        added.members.map(&.id).should contain added.member.id
      ensure
        remaining = client.cluster.member_remove(added.member.id)
        remaining.map(&.id).should_not contain added.member.id
      end
    end
  end

  describe Client do
    it "closes, and closes again" do
      client = Etcd.from_env
      client.kv.put("#{TEST_PREFIX}/close", "one")
      client.close
      client.api.connection.not_nil!.closed?.should be_true
      client.close
    end
  end
end
