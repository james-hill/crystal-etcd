## Generated from rpc.proto for etcdserverpb
require "protobuf"

require "./kv.pb.cr"
require "./auth.pb.cr"
require "./version.pb.cr"
require "./annotations.pb.cr"
require "./annotations2.pb.cr"

module Etcdserverpb
  enum AlarmType
    NONE = 0
    NOSPACE = 1
    CORRUPT = 2
  end
  
  struct ResponseHeader
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :cluster_id, :uint64, 1
      optional :member_id, :uint64, 2
      optional :revision, :int64, 3
      optional :raft_term, :uint64, 4
    end
  end
  
  struct RangeRequest
    include ::Protobuf::Message
    enum SortOrder
      NONE = 0
      ASCEND = 1
      DESCEND = 2
    end
    enum SortTarget
      KEY = 0
      VERSION = 1
      CREATE = 2
      MOD = 3
      VALUE = 4
    end
    
    contract_of "proto3" do
      optional :key, :bytes, 1
      optional :range_end, :bytes, 2
      optional :limit, :int64, 3
      optional :revision, :int64, 4
      optional :sort_order, RangeRequest::SortOrder, 5
      optional :sort_target, RangeRequest::SortTarget, 6
      optional :serializable, :bool, 7
      optional :keys_only, :bool, 8
      optional :count_only, :bool, 9
      optional :min_mod_revision, :int64, 10
      optional :max_mod_revision, :int64, 11
      optional :min_create_revision, :int64, 12
      optional :max_create_revision, :int64, 13
    end
  end
  
  struct RangeResponse
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :header, ResponseHeader, 1
      repeated :kvs, Mvccpb::KeyValue, 2
      optional :more, :bool, 3
      optional :count, :int64, 4
    end
  end
  
  struct PutRequest
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :key, :bytes, 1
      optional :value, :bytes, 2
      optional :lease, :int64, 3
      optional :prev_kv, :bool, 4
      optional :ignore_value, :bool, 5
      optional :ignore_lease, :bool, 6
    end
  end
  
  struct PutResponse
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :header, ResponseHeader, 1
      optional :prev_kv, Mvccpb::KeyValue, 2
    end
  end
  
  struct DeleteRangeRequest
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :key, :bytes, 1
      optional :range_end, :bytes, 2
      optional :prev_kv, :bool, 3
    end
  end
  
  struct DeleteRangeResponse
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :header, ResponseHeader, 1
      optional :deleted, :int64, 2
      repeated :prev_kvs, Mvccpb::KeyValue, 3
    end
  end
  
  struct RequestOp
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :request_range, RangeRequest, 1
      optional :request_put, PutRequest, 2
      optional :request_delete_range, DeleteRangeRequest, 3
      optional :request_txn, TxnRequest, 4
    end
  end
  
  struct ResponseOp
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :response_range, RangeResponse, 1
      optional :response_put, PutResponse, 2
      optional :response_delete_range, DeleteRangeResponse, 3
      optional :response_txn, TxnResponse, 4
    end
  end
  
  struct Compare
    include ::Protobuf::Message
    enum CompareResult
      EQUAL = 0
      GREATER = 1
      LESS = 2
      NOT_EQUAL = 3
      NOTEQUAL = 3
    end
    enum CompareTarget
      VERSION = 0
      CREATE = 1
      MOD = 2
      VALUE = 3
      LEASE = 4
    end
    
    contract_of "proto3" do
      optional :result, Compare::CompareResult, 1
      optional :target, Compare::CompareTarget, 2
      optional :key, :bytes, 3
      optional :version, :int64, 4
      optional :create_revision, :int64, 5
      optional :mod_revision, :int64, 6
      optional :value, :bytes, 7
      optional :lease, :int64, 8
      optional :range_end, :bytes, 64
    end
  end
  
  struct TxnRequest
    include ::Protobuf::Message
    
    contract_of "proto3" do
      repeated :compare, Compare, 1
      repeated :success, RequestOp, 2
      repeated :failure, RequestOp, 3
    end
  end
  
  struct TxnResponse
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :header, ResponseHeader, 1
      optional :succeeded, :bool, 2
      repeated :responses, ResponseOp, 3
    end
  end
  
  struct CompactionRequest
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :revision, :int64, 1
      optional :physical, :bool, 2
    end
  end
  
  struct CompactionResponse
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :header, ResponseHeader, 1
    end
  end
  
  struct HashRequest
    include ::Protobuf::Message
    
    contract_of "proto3" do
    end
  end
  
  struct HashKVRequest
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :revision, :int64, 1
    end
  end
  
  struct HashKVResponse
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :header, ResponseHeader, 1
      optional :hash, :uint32, 2
      optional :compact_revision, :int64, 3
      optional :hash_revision, :int64, 4
    end
  end
  
  struct HashResponse
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :header, ResponseHeader, 1
      optional :hash, :uint32, 2
    end
  end
  
  struct SnapshotRequest
    include ::Protobuf::Message
    
    contract_of "proto3" do
    end
  end
  
  struct SnapshotResponse
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :header, ResponseHeader, 1
      optional :remaining_bytes, :uint64, 2
      optional :blob, :bytes, 3
      optional :version, :string, 4
    end
  end
  
  struct WatchRequest
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :create_request, WatchCreateRequest, 1
      optional :cancel_request, WatchCancelRequest, 2
      optional :progress_request, WatchProgressRequest, 3
    end
  end
  
  struct WatchCreateRequest
    include ::Protobuf::Message
    enum FilterType
      NOPUT = 0
      NODELETE = 1
    end
    
    contract_of "proto3" do
      optional :key, :bytes, 1
      optional :range_end, :bytes, 2
      optional :start_revision, :int64, 3
      optional :progress_notify, :bool, 4
      repeated :filters, WatchCreateRequest::FilterType, 5
      optional :prev_kv, :bool, 6
      optional :watch_id, :int64, 7
      optional :fragment, :bool, 8
    end
  end
  
  struct WatchCancelRequest
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :watch_id, :int64, 1
    end
  end
  
  struct WatchProgressRequest
    include ::Protobuf::Message
    
    contract_of "proto3" do
    end
  end
  
  struct WatchResponse
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :header, ResponseHeader, 1
      optional :watch_id, :int64, 2
      optional :created, :bool, 3
      optional :canceled, :bool, 4
      optional :compact_revision, :int64, 5
      optional :cancel_reason, :string, 6
      optional :fragment, :bool, 7
      repeated :events, Mvccpb::Event, 11
    end
  end
  
  struct LeaseGrantRequest
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :ttl, :int64, 1
      optional :id, :int64, 2
    end
  end
  
  struct LeaseGrantResponse
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :header, ResponseHeader, 1
      optional :id, :int64, 2
      optional :ttl, :int64, 3
      optional :error, :string, 4
    end
  end
  
  struct LeaseRevokeRequest
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :id, :int64, 1
    end
  end
  
  struct LeaseRevokeResponse
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :header, ResponseHeader, 1
    end
  end
  
  struct LeaseCheckpoint
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :id, :int64, 1
      optional :remaining_ttl, :int64, 2
    end
  end
  
  struct LeaseCheckpointRequest
    include ::Protobuf::Message
    
    contract_of "proto3" do
      repeated :checkpoints, LeaseCheckpoint, 1
    end
  end
  
  struct LeaseCheckpointResponse
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :header, ResponseHeader, 1
    end
  end
  
  struct LeaseKeepAliveRequest
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :id, :int64, 1
    end
  end
  
  struct LeaseKeepAliveResponse
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :header, ResponseHeader, 1
      optional :id, :int64, 2
      optional :ttl, :int64, 3
    end
  end
  
  struct LeaseTimeToLiveRequest
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :id, :int64, 1
      optional :keys, :bool, 2
    end
  end
  
  struct LeaseTimeToLiveResponse
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :header, ResponseHeader, 1
      optional :id, :int64, 2
      optional :ttl, :int64, 3
      optional :granted_ttl, :int64, 4
      repeated :keys, :bytes, 5
    end
  end
  
  struct LeaseLeasesRequest
    include ::Protobuf::Message
    
    contract_of "proto3" do
    end
  end
  
  struct LeaseStatus
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :id, :int64, 1
    end
  end
  
  struct LeaseLeasesResponse
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :header, ResponseHeader, 1
      repeated :leases, LeaseStatus, 2
    end
  end
  
  struct Member
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :id, :uint64, 1
      optional :name, :string, 2
      repeated :peer_ur_ls, :string, 3
      repeated :client_ur_ls, :string, 4
      optional :is_learner, :bool, 5
    end
  end
  
  struct MemberAddRequest
    include ::Protobuf::Message
    
    contract_of "proto3" do
      repeated :peer_ur_ls, :string, 1
      optional :is_learner, :bool, 2
    end
  end
  
  struct MemberAddResponse
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :header, ResponseHeader, 1
      optional :member, Member, 2
      repeated :members, Member, 3
    end
  end
  
  struct MemberRemoveRequest
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :id, :uint64, 1
    end
  end
  
  struct MemberRemoveResponse
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :header, ResponseHeader, 1
      repeated :members, Member, 2
    end
  end
  
  struct MemberUpdateRequest
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :id, :uint64, 1
      repeated :peer_ur_ls, :string, 2
    end
  end
  
  struct MemberUpdateResponse
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :header, ResponseHeader, 1
      repeated :members, Member, 2
    end
  end
  
  struct MemberListRequest
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :linearizable, :bool, 1
    end
  end
  
  struct MemberListResponse
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :header, ResponseHeader, 1
      repeated :members, Member, 2
    end
  end
  
  struct MemberPromoteRequest
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :id, :uint64, 1
    end
  end
  
  struct MemberPromoteResponse
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :header, ResponseHeader, 1
      repeated :members, Member, 2
    end
  end
  
  struct DefragmentRequest
    include ::Protobuf::Message
    
    contract_of "proto3" do
    end
  end
  
  struct DefragmentResponse
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :header, ResponseHeader, 1
    end
  end
  
  struct MoveLeaderRequest
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :target_id, :uint64, 1
    end
  end
  
  struct MoveLeaderResponse
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :header, ResponseHeader, 1
    end
  end
  
  struct AlarmRequest
    include ::Protobuf::Message
    enum AlarmAction
      GET = 0
      ACTIVATE = 1
      DEACTIVATE = 2
    end
    
    contract_of "proto3" do
      optional :action, AlarmRequest::AlarmAction, 1
      optional :member_id, :uint64, 2
      optional :alarm, AlarmType, 3
    end
  end
  
  struct AlarmMember
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :member_id, :uint64, 1
      optional :alarm, AlarmType, 2
    end
  end
  
  struct AlarmResponse
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :header, ResponseHeader, 1
      repeated :alarms, AlarmMember, 2
    end
  end
  
  struct DowngradeRequest
    include ::Protobuf::Message
    enum DowngradeAction
      VALIDATE = 0
      ENABLE = 1
      CANCEL = 2
    end
    
    contract_of "proto3" do
      optional :action, DowngradeRequest::DowngradeAction, 1
      optional :version, :string, 2
    end
  end
  
  struct DowngradeResponse
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :header, ResponseHeader, 1
      optional :version, :string, 2
    end
  end
  
  struct DowngradeVersionTestRequest
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :ver, :string, 1
    end
  end
  
  struct StatusRequest
    include ::Protobuf::Message
    
    contract_of "proto3" do
    end
  end
  
  struct StatusResponse
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :header, ResponseHeader, 1
      optional :version, :string, 2
      optional :db_size, :int64, 3
      optional :leader, :uint64, 4
      optional :raft_index, :uint64, 5
      optional :raft_term, :uint64, 6
      optional :raft_applied_index, :uint64, 7
      repeated :errors, :string, 8
      optional :db_size_in_use, :int64, 9
      optional :is_learner, :bool, 10
      optional :storage_version, :string, 11
      optional :db_size_quota, :int64, 12
      optional :downgrade_info, DowngradeInfo, 13
    end
  end
  
  struct DowngradeInfo
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :enabled, :bool, 1
      optional :target_version, :string, 2
    end
  end
  
  struct AuthEnableRequest
    include ::Protobuf::Message
    
    contract_of "proto3" do
    end
  end
  
  struct AuthDisableRequest
    include ::Protobuf::Message
    
    contract_of "proto3" do
    end
  end
  
  struct AuthStatusRequest
    include ::Protobuf::Message
    
    contract_of "proto3" do
    end
  end
  
  struct AuthenticateRequest
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :name, :string, 1
      optional :password, :string, 2
    end
  end
  
  struct AuthUserAddRequest
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :name, :string, 1
      optional :password, :string, 2
      optional :options, Authpb::UserAddOptions, 3
      optional :hashed_password, :string, 4
    end
  end
  
  struct AuthUserGetRequest
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :name, :string, 1
    end
  end
  
  struct AuthUserDeleteRequest
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :name, :string, 1
    end
  end
  
  struct AuthUserChangePasswordRequest
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :name, :string, 1
      optional :password, :string, 2
      optional :hashed_password, :string, 3
    end
  end
  
  struct AuthUserGrantRoleRequest
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :user, :string, 1
      optional :role, :string, 2
    end
  end
  
  struct AuthUserRevokeRoleRequest
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :name, :string, 1
      optional :role, :string, 2
    end
  end
  
  struct AuthRoleAddRequest
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :name, :string, 1
    end
  end
  
  struct AuthRoleGetRequest
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :role, :string, 1
    end
  end
  
  struct AuthUserListRequest
    include ::Protobuf::Message
    
    contract_of "proto3" do
    end
  end
  
  struct AuthRoleListRequest
    include ::Protobuf::Message
    
    contract_of "proto3" do
    end
  end
  
  struct AuthRoleDeleteRequest
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :role, :string, 1
    end
  end
  
  struct AuthRoleGrantPermissionRequest
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :name, :string, 1
      optional :perm, Authpb::Permission, 2
    end
  end
  
  struct AuthRoleRevokePermissionRequest
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :role, :string, 1
      optional :key, :bytes, 2
      optional :range_end, :bytes, 3
    end
  end
  
  struct AuthEnableResponse
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :header, ResponseHeader, 1
    end
  end
  
  struct AuthDisableResponse
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :header, ResponseHeader, 1
    end
  end
  
  struct AuthStatusResponse
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :header, ResponseHeader, 1
      optional :enabled, :bool, 2
      optional :auth_revision, :uint64, 3
    end
  end
  
  struct AuthenticateResponse
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :header, ResponseHeader, 1
      optional :token, :string, 2
    end
  end
  
  struct AuthUserAddResponse
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :header, ResponseHeader, 1
    end
  end
  
  struct AuthUserGetResponse
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :header, ResponseHeader, 1
      repeated :roles, :string, 2
    end
  end
  
  struct AuthUserDeleteResponse
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :header, ResponseHeader, 1
    end
  end
  
  struct AuthUserChangePasswordResponse
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :header, ResponseHeader, 1
    end
  end
  
  struct AuthUserGrantRoleResponse
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :header, ResponseHeader, 1
    end
  end
  
  struct AuthUserRevokeRoleResponse
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :header, ResponseHeader, 1
    end
  end
  
  struct AuthRoleAddResponse
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :header, ResponseHeader, 1
    end
  end
  
  struct AuthRoleGetResponse
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :header, ResponseHeader, 1
      repeated :perm, Authpb::Permission, 2
    end
  end
  
  struct AuthRoleListResponse
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :header, ResponseHeader, 1
      repeated :roles, :string, 2
    end
  end
  
  struct AuthUserListResponse
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :header, ResponseHeader, 1
      repeated :users, :string, 2
    end
  end
  
  struct AuthRoleDeleteResponse
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :header, ResponseHeader, 1
    end
  end
  
  struct AuthRoleGrantPermissionResponse
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :header, ResponseHeader, 1
    end
  end
  
  struct AuthRoleRevokePermissionResponse
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :header, ResponseHeader, 1
    end
  end
  end
