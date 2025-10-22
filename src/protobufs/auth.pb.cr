## Generated from auth.proto for authpb
require "protobuf"

module Authpb
  
  struct UserAddOptions
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :no_password, :bool, 1
    end
  end
  
  struct User
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :name, :bytes, 1
      optional :password, :bytes, 2
      repeated :roles, :string, 3
      optional :options, UserAddOptions, 4
    end
  end
  
  struct Permission
    include ::Protobuf::Message
    enum Type
      READ = 0
      WRITE = 1
      READWRITE = 2
    end
    
    contract_of "proto3" do
      optional :perm_type, Permission::Type, 1
      optional :key, :bytes, 2
      optional :range_end, :bytes, 3
    end
  end
  
  struct Role
    include ::Protobuf::Message
    
    contract_of "proto3" do
      optional :name, :bytes, 1
      repeated :key_permission, Permission, 2
    end
  end
  end
