require "./base"

module Etcd::Model
  struct MemberAdd
    getter member : Member
    getter members = [] of Member

    def initialize(@member : Member, @members : Array(Member))
    end
  end

  struct Member
    getter! id : UInt64
    getter! client_urls : Array(String)
    getter! is_learner : Bool
    getter! name : String
    getter! peer_urls : Array(String)

    def self.from_grpc(member : Etcdserverpb::Member)
      new(
        id: member.id,
        name: member.name,
        client_urls: member.client_urls,
        peer_urls: member.peer_urls,
        is_learner: member.is_learner,
      )
    end

    def initialize(@id, @name, @client_urls, @peer_urls, @is_learner)
    end
  end
end
