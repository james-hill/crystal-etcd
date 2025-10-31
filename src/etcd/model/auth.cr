require "./base"

module Etcd::Model
  struct Token < WithHeader
    getter token : String
  end

  struct Permissions < WithHeader
    getter perm = [] of Permission
  end

  enum PermissionType
    READ
    WRITE
    READWRITE

    def self.from_etcd_perm_type(type : Authpb::Permission::Type)
      case type
      when Authpb::Permission::READ
        PermissionType::READ
      when Authpb::Permission::WRITE
        PermissionType::WRITE
      when Authpb::Permission::READWRITE
        PermissionType::READWRITE
      else
        raise "Unknown permission type: #{type}"
      end
    end

    def to_etcd_perm_type
      case self
      when .read?
        Authpb::Permission::Type::READ
      when .write?
        Authpb::Permission::Type::WRITE
      when .readwrite?
        Authpb::Permission::Type::READWRITE
      else
        raise "Unknown permission type: #{self}"
      end
    end
  end

  struct Permission
    getter key : String # Bytes
    @[JSON::Field(key: "permType")]
    getter perm_type : PermissionType = PermissionType::READ
    getter range_end : String? = nil # Bytes

    def initialize(@key, @perm_type = PermissionType::READ, @range_end : String? = nil)
    end
  end

end
