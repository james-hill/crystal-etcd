require "./model/cluster"

class Etcd::Cluster
  getter stub : Etcdserverpb::Cluster::Stub

  def initialize(@config : GRPC::Config)
    @stub = Etcdserverpb::Cluster::Stub.new(@config)
  end

  # POST cluster/member/add
  def member_add(is_learner : Bool, peer_urls : Array(String))
    response = stub.member_add(Etcdserverpb::MemberAddRequest.new(is_learner: is_learner, peer_urls: peer_urls))
    Model::MemberAdd.new(
      member: Model::Member.from_grpc(response.member),
      members: (response.members || [] of Etcdserverpb::Member).map { |member| Model::Member.from_grpc(member) },
    )
  end

  # POST cluster/member/list
  def member_list
    response = stub.member_list(Etcdserverpb::MemberListRequest.new)
    (response.members || [] of Etcdserverpb::Member).map do |member|
      Model::Member.from_grpc(member)
    end
  end

  # POST cluster/member/promote
  def member_promote(id : UInt64)
    response = client.api.post("/cluster/member/promote", {ID: id}).body
    Model::Cluster::Members.from_json(response).members
  end

  # POST cluster/member/remove
  def member_remove(id : UInt64)
    response = client.api.post("/cluster/member/remove", {ID: id}).body
    Model::Cluster::Members.from_json(response).members
  end

  # POST cluster/member/update
  def member_update(id : UInt64, peer_urls : Array(String))
    response = client.api.post("/cluster/member/update", {ID: id, peerURLs: peer_urls}).body
    Model::Cluster::Members.from_json(response).members
  end
end
