require "./model/auth"
require "./utils"

class Etcd::Auth
  include Utils

  getter stub : Etcdserverpb::Auth::Stub

  def initialize(config : GRPC::Config)
    @stub = Etcdserverpb::Auth::Stub.new(config)
  end

  # auth/disable
  def disable
    stub.auth_disable(Etcdserverpb::AuthDisableRequest.new).is_a?(Etcdserverpb::AuthDisableResponse)
  end

  # auth/enable
  def enable
    stub.auth_enable(Etcdserverpb::AuthEnableRequest.new).is_a?(Etcdserverpb::AuthEnableResponse)
  end

  def enabled?
    stub.auth_status(Etcdserverpb::AuthStatusRequest.new).enabled == true
  end

  def authenticate(username : String, password : String)
    stub.authenticate(Etcdserverpb::AuthenticateRequest.new(name: username, password: password)).token
  end

  # auth/role/add
  def role_add(name : String)
    validate!(name)

    stub.role_add(Etcdserverpb::AuthRoleAddRequest.new(name: name)).is_a?(Etcdserverpb::AuthRoleAddResponse)
  end

  # auth/role/delete
  def role_delete(role : String)
    stub.role_delete(Etcdserverpb::AuthRoleDeleteRequest.new(role: role)).is_a?(Etcdserverpb::AuthRoleDeleteResponse)
  end

  # auth/role/get
  def role_get(role : String)
    perms = stub.role_get(Etcdserverpb::AuthRoleGetRequest.new(role: role)).perm || [] of Authpb::Permission
    perms.map do |perm|
      if key = perm.key
        Model::Permission.new(
          key.to_s,
          Model::PermissionType.from_grpc(perm.perm_type),
          perm.range_end.try(&.to_s)
        )
      end
    end
  end

  # auth/role/grant
  # Note: base64_keys is deprected now that we use gRPC
  def role_grant(role : String, perm_key : String, range_end : String | Slice(UInt8)? = nil, perm_type : Model::PermissionType = Model::PermissionType::READ, base64_keys : Bool = true)
    validate!(role)

    request = Etcdserverpb::AuthRoleGrantPermissionRequest.new(
      name: role,
      perm:  Authpb::Permission.new(
        key:       perm_key.to_slice,
        perm_type: perm_type.to_etcd_perm_type,
        range_end: range_end,
      ),
    )

    stub.role_grant_permission(request).is_a?(Etcdserverpb::AuthRoleGrantPermissionResponse)
  end

  def role_grant_prefix(name : String, prefix : String, perm_type = Model::PermissionType::READ)
    range_end = prefix_range_end prefix
    role_grant(name, prefix, range_end, perm_type)
  end

  # auth/role/list
  def role_list
    stub.role_list(Etcdserverpb::AuthRoleListRequest.new).roles || [] of String
  end

  # auth/role/revoke
  # Note: base64_keys is deprected now that we use gRPC
  def role_revoke(role : String, key : String, range_end : String | Slice(UInt8)? = nil, base64_keys : Bool = true)
    validate!(role)

    request = Etcdserverpb::AuthRoleRevokePermissionRequest.new(
      role: role,
      key: key.to_slice,
      range_end: range_end,
    )

    stub.role_revoke_permission(request).is_a?(Etcdserverpb::AuthRoleRevokePermissionResponse)
  end

  def role_revoke_prefix(role : String, prefix : String)
    range_end = prefix_range_end prefix
    role_revoke(role, prefix, range_end)
  end

  # auth/user/add
  def user_add(name : String, password : String, no_password : Bool = false)
    validate!(name)

    request = Etcdserverpb::AuthUserAddRequest.new(
      name: name,
      password: password,
      options: Authpb::UserAddOptions.new(no_password: no_password),
    )

    stub.user_add(request).is_a?(Etcdserverpb::AuthUserAddResponse)
  end

  # auth/user/changepw
  def user_changepw(name : String, password : String)
    validate!(name)

    request = Etcdserverpb::AuthUserChangePasswordRequest.new(
      name: name,
      password: password,
    )

    stub.user_change_password(request).is_a?(Etcdserverpb::AuthUserChangePasswordResponse)
  end

  # auth/user/delete
  def user_delete(name : String)
    validate!(name)

    stub.user_delete(Etcdserverpb::AuthUserDeleteRequest.new(name: name)).is_a?(Etcdserverpb::AuthUserDeleteResponse)
  end

  # auth/user/get
  def user_get(name : String)
    validate!(name)

    stub.user_get(Etcdserverpb::AuthUserGetRequest.new(name: name)).roles
  end

  # auth/user/grant
  def user_grant(role : String, user : String)
    stub.user_grant_role(Etcdserverpb::AuthUserGrantRoleRequest.new(user: user, role: role)).is_a?(Etcdserverpb::AuthUserGrantRoleResponse)
  end

  # auth/user/list
  def user_list
    stub.user_list(Etcdserverpb::AuthUserListRequest.new).users || [] of String
  end

  # auth/user/revoke
  def user_revoke(name : String, role : String)
    validate!(name)
    stub.user_revoke_role(Etcdserverpb::AuthUserRevokeRoleRequest.new(user: name, role: role)).is_a?(Etcdserverpb::AuthUserRevokeRoleResponse)
  end

  private def validate!(name : String)
    raise ArgumentError.new("`name` is empty") if name.empty?
  end
end
