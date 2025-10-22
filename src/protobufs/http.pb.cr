## Generated from google/api/http.proto for google.api
require "protobuf"

module Google
  module Api
    
    struct Http
      include ::Protobuf::Message
      
      contract_of "proto3" do
        repeated :rules, HttpRule, 1
        optional :fully_decode_reserved_expansion, :bool, 2
      end
    end
    
    class HttpRule
      include ::Protobuf::Message
      
      contract_of "proto3" do
        optional :selector, :string, 1
        optional :get, :string, 2
        optional :put, :string, 3
        optional :post, :string, 4
        optional :delete, :string, 5
        optional :patch, :string, 6
        optional :custom, CustomHttpPattern, 8
        optional :body, :string, 7
        optional :response_body, :string, 12
        repeated :additional_bindings, HttpRule, 11
      end
    end
    
    struct CustomHttpPattern
      include ::Protobuf::Message
      
      contract_of "proto3" do
        optional :kind, :string, 1
        optional :path, :string, 2
      end
    end
    end
  end
