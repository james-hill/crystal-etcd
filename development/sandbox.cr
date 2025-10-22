require "../src/etcd"

EtcdService = Etcdserverpb::Maintenance::Stub.new("127.0.0.1", 2379)

pp EtcdService.status(::Etcdserverpb::StatusRequest.new)
