## Generated from rpc.proto for etcdserverpb
require "grpc/service"

require "./kv.pb.cr"
require "./auth.pb.cr"
require "./version.pb.cr"
require "./annotations.pb.cr"
require "./annotations2.pb.cr"

module Etcdserverpb
  abstract class Etcdserverpb::KV
    include GRPC::Service

    @@service_name = "etcdserverpb.KV"

    rpc Range, receives: ::Etcdserverpb::RangeRequest, returns: ::Etcdserverpb::RangeResponse
    rpc Put, receives: ::Etcdserverpb::PutRequest, returns: ::Etcdserverpb::PutResponse
    rpc DeleteRange, receives: ::Etcdserverpb::DeleteRangeRequest, returns: ::Etcdserverpb::DeleteRangeResponse
    rpc Txn, receives: ::Etcdserverpb::TxnRequest, returns: ::Etcdserverpb::TxnResponse
    rpc Compact, receives: ::Etcdserverpb::CompactionRequest, returns: ::Etcdserverpb::CompactionResponse
  end
  abstract class Etcdserverpb::Watch
    include GRPC::Service

    @@service_name = "etcdserverpb.Watch"

    rpc Watch, receives: ::Etcdserverpb::WatchRequest, returns: ::Etcdserverpb::WatchResponse
  end
  abstract class Etcdserverpb::Lease
    include GRPC::Service

    @@service_name = "etcdserverpb.Lease"

    rpc LeaseGrant, receives: ::Etcdserverpb::LeaseGrantRequest, returns: ::Etcdserverpb::LeaseGrantResponse
    rpc LeaseRevoke, receives: ::Etcdserverpb::LeaseRevokeRequest, returns: ::Etcdserverpb::LeaseRevokeResponse
    rpc LeaseKeepAlive, receives: ::Etcdserverpb::LeaseKeepAliveRequest, returns: ::Etcdserverpb::LeaseKeepAliveResponse
    rpc LeaseTimeToLive, receives: ::Etcdserverpb::LeaseTimeToLiveRequest, returns: ::Etcdserverpb::LeaseTimeToLiveResponse
    rpc LeaseLeases, receives: ::Etcdserverpb::LeaseLeasesRequest, returns: ::Etcdserverpb::LeaseLeasesResponse
  end
  abstract class Etcdserverpb::Cluster
    include GRPC::Service

    @@service_name = "etcdserverpb.Cluster"

    rpc MemberAdd, receives: ::Etcdserverpb::MemberAddRequest, returns: ::Etcdserverpb::MemberAddResponse
    rpc MemberRemove, receives: ::Etcdserverpb::MemberRemoveRequest, returns: ::Etcdserverpb::MemberRemoveResponse
    rpc MemberUpdate, receives: ::Etcdserverpb::MemberUpdateRequest, returns: ::Etcdserverpb::MemberUpdateResponse
    rpc MemberList, receives: ::Etcdserverpb::MemberListRequest, returns: ::Etcdserverpb::MemberListResponse
    rpc MemberPromote, receives: ::Etcdserverpb::MemberPromoteRequest, returns: ::Etcdserverpb::MemberPromoteResponse
  end
  abstract class Etcdserverpb::Maintenance
    include GRPC::Service

    @@service_name = "etcdserverpb.Maintenance"

    rpc Alarm, receives: ::Etcdserverpb::AlarmRequest, returns: ::Etcdserverpb::AlarmResponse
    rpc Status, receives: ::Etcdserverpb::StatusRequest, returns: ::Etcdserverpb::StatusResponse
    rpc Defragment, receives: ::Etcdserverpb::DefragmentRequest, returns: ::Etcdserverpb::DefragmentResponse
    rpc Hash, receives: ::Etcdserverpb::HashRequest, returns: ::Etcdserverpb::HashResponse
    rpc HashKV, receives: ::Etcdserverpb::HashKVRequest, returns: ::Etcdserverpb::HashKVResponse
    rpc Snapshot, receives: ::Etcdserverpb::SnapshotRequest, returns: ::Etcdserverpb::SnapshotResponse
    rpc MoveLeader, receives: ::Etcdserverpb::MoveLeaderRequest, returns: ::Etcdserverpb::MoveLeaderResponse
    rpc Downgrade, receives: ::Etcdserverpb::DowngradeRequest, returns: ::Etcdserverpb::DowngradeResponse
  end
  abstract class Etcdserverpb::Auth
    include GRPC::Service

    @@service_name = "etcdserverpb.Auth"

    rpc AuthEnable, receives: ::Etcdserverpb::AuthEnableRequest, returns: ::Etcdserverpb::AuthEnableResponse
    rpc AuthDisable, receives: ::Etcdserverpb::AuthDisableRequest, returns: ::Etcdserverpb::AuthDisableResponse
    rpc AuthStatus, receives: ::Etcdserverpb::AuthStatusRequest, returns: ::Etcdserverpb::AuthStatusResponse
    rpc Authenticate, receives: ::Etcdserverpb::AuthenticateRequest, returns: ::Etcdserverpb::AuthenticateResponse
    rpc UserAdd, receives: ::Etcdserverpb::AuthUserAddRequest, returns: ::Etcdserverpb::AuthUserAddResponse
    rpc UserGet, receives: ::Etcdserverpb::AuthUserGetRequest, returns: ::Etcdserverpb::AuthUserGetResponse
    rpc UserList, receives: ::Etcdserverpb::AuthUserListRequest, returns: ::Etcdserverpb::AuthUserListResponse
    rpc UserDelete, receives: ::Etcdserverpb::AuthUserDeleteRequest, returns: ::Etcdserverpb::AuthUserDeleteResponse
    rpc UserChangePassword, receives: ::Etcdserverpb::AuthUserChangePasswordRequest, returns: ::Etcdserverpb::AuthUserChangePasswordResponse
    rpc UserGrantRole, receives: ::Etcdserverpb::AuthUserGrantRoleRequest, returns: ::Etcdserverpb::AuthUserGrantRoleResponse
    rpc UserRevokeRole, receives: ::Etcdserverpb::AuthUserRevokeRoleRequest, returns: ::Etcdserverpb::AuthUserRevokeRoleResponse
    rpc RoleAdd, receives: ::Etcdserverpb::AuthRoleAddRequest, returns: ::Etcdserverpb::AuthRoleAddResponse
    rpc RoleGet, receives: ::Etcdserverpb::AuthRoleGetRequest, returns: ::Etcdserverpb::AuthRoleGetResponse
    rpc RoleList, receives: ::Etcdserverpb::AuthRoleListRequest, returns: ::Etcdserverpb::AuthRoleListResponse
    rpc RoleDelete, receives: ::Etcdserverpb::AuthRoleDeleteRequest, returns: ::Etcdserverpb::AuthRoleDeleteResponse
    rpc RoleGrantPermission, receives: ::Etcdserverpb::AuthRoleGrantPermissionRequest, returns: ::Etcdserverpb::AuthRoleGrantPermissionResponse
    rpc RoleRevokePermission, receives: ::Etcdserverpb::AuthRoleRevokePermissionRequest, returns: ::Etcdserverpb::AuthRoleRevokePermissionResponse
  end
end
