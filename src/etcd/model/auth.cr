require "./base"

module Etcd::Model
  struct Permissions 
    getter perm = [] of Permission
  end

  enum PermissionType
    READ
    WRITE
    READWRITE

    def self.from_grpc(type : Authpb::Permission::Type?)
      case type
      when Authpb::Permission::Type::READ, nil
        PermissionType::READ
      when Authpb::Permission::Type::WRITE
        PermissionType::WRITE
      when Authpb::Permission::Type::READWRITE
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
    getter perm_type : PermissionType = PermissionType::READ
    getter range_end : String? = nil # Bytes

    def initialize(@key, @perm_type = PermissionType::READ, @range_end : String? = nil)
    end
  end

end
