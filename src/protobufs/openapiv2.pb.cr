## Generated from protoc-gen-openapiv2/options/openapiv2.proto for grpc.gateway.protoc_gen_openapiv2.options
require "protobuf"

require "./struct.pb.cr"

module Grpc
  module Gateway
    module ProtocGenOpenapiv2
      module Options
        enum Scheme
          UNKNOWN = 0
          HTTP = 1
          HTTPS = 2
          WS = 3
          WSS = 4
        end
        
        struct Swagger
          include ::Protobuf::Message
          
          struct ResponsesEntry
            include ::Protobuf::Message
            
            contract_of "proto3" do
              optional :key, :string, 1
              optional :value, Response, 2
            end
          end
          
          struct ExtensionsEntry
            include ::Protobuf::Message
            
            contract_of "proto3" do
              optional :key, :string, 1
              optional :value, Google::Protobuf::Value, 2
            end
          end
          
          contract_of "proto3" do
            optional :swagger, :string, 1
            optional :info, Info, 2
            optional :host, :string, 3
            optional :base_path, :string, 4
            repeated :schemes, Scheme, 5
            repeated :consumes, :string, 6
            repeated :produces, :string, 7
            repeated :responses, Swagger::ResponsesEntry, 10
            optional :security_definitions, SecurityDefinitions, 11
            repeated :security, SecurityRequirement, 12
            repeated :tags, Tag, 13
            optional :external_docs, ExternalDocumentation, 14
            repeated :extensions, Swagger::ExtensionsEntry, 15
          end
        end
        
        struct Operation
          include ::Protobuf::Message
          
          struct ResponsesEntry
            include ::Protobuf::Message
            
            contract_of "proto3" do
              optional :key, :string, 1
              optional :value, Response, 2
            end
          end
          
          struct ExtensionsEntry
            include ::Protobuf::Message
            
            contract_of "proto3" do
              optional :key, :string, 1
              optional :value, Google::Protobuf::Value, 2
            end
          end
          
          contract_of "proto3" do
            repeated :tags, :string, 1
            optional :summary, :string, 2
            optional :description, :string, 3
            optional :external_docs, ExternalDocumentation, 4
            optional :operation_id, :string, 5
            repeated :consumes, :string, 6
            repeated :produces, :string, 7
            repeated :responses, Operation::ResponsesEntry, 9
            repeated :schemes, Scheme, 10
            optional :deprecated, :bool, 11
            repeated :security, SecurityRequirement, 12
            repeated :extensions, Operation::ExtensionsEntry, 13
            optional :parameters, Parameters, 14
          end
        end
        
        struct Parameters
          include ::Protobuf::Message
          
          contract_of "proto3" do
            repeated :headers, HeaderParameter, 1
          end
        end
        
        struct HeaderParameter
          include ::Protobuf::Message
          enum Type
            UNKNOWN = 0
            STRING = 1
            NUMBER = 2
            INTEGER = 3
            BOOLEAN = 4
          end
          
          contract_of "proto3" do
            optional :name, :string, 1
            optional :description, :string, 2
            optional :type, HeaderParameter::Type, 3
            optional :format, :string, 4
            optional :required, :bool, 5
          end
        end
        
        struct Header
          include ::Protobuf::Message
          
          contract_of "proto3" do
            optional :description, :string, 1
            optional :type, :string, 2
            optional :format, :string, 3
            optional :default, :string, 6
            optional :pattern, :string, 13
          end
        end
        
        struct Response
          include ::Protobuf::Message
          
          struct HeadersEntry
            include ::Protobuf::Message
            
            contract_of "proto3" do
              optional :key, :string, 1
              optional :value, Header, 2
            end
          end
          
          struct ExamplesEntry
            include ::Protobuf::Message
            
            contract_of "proto3" do
              optional :key, :string, 1
              optional :value, :string, 2
            end
          end
          
          struct ExtensionsEntry
            include ::Protobuf::Message
            
            contract_of "proto3" do
              optional :key, :string, 1
              optional :value, Google::Protobuf::Value, 2
            end
          end
          
          contract_of "proto3" do
            optional :description, :string, 1
            optional :schema, Schema, 2
            repeated :headers, Response::HeadersEntry, 3
            repeated :examples, Response::ExamplesEntry, 4
            repeated :extensions, Response::ExtensionsEntry, 5
          end
        end
        
        struct Info
          include ::Protobuf::Message
          
          struct ExtensionsEntry
            include ::Protobuf::Message
            
            contract_of "proto3" do
              optional :key, :string, 1
              optional :value, Google::Protobuf::Value, 2
            end
          end
          
          contract_of "proto3" do
            optional :title, :string, 1
            optional :description, :string, 2
            optional :terms_of_service, :string, 3
            optional :contact, Contact, 4
            optional :license, License, 5
            optional :version, :string, 6
            repeated :extensions, Info::ExtensionsEntry, 7
          end
        end
        
        struct Contact
          include ::Protobuf::Message
          
          contract_of "proto3" do
            optional :name, :string, 1
            optional :url, :string, 2
            optional :email, :string, 3
          end
        end
        
        struct License
          include ::Protobuf::Message
          
          contract_of "proto3" do
            optional :name, :string, 1
            optional :url, :string, 2
          end
        end
        
        struct ExternalDocumentation
          include ::Protobuf::Message
          
          contract_of "proto3" do
            optional :description, :string, 1
            optional :url, :string, 2
          end
        end
        
        struct Schema
          include ::Protobuf::Message
          
          contract_of "proto3" do
            optional :json_schema, JSONSchema, 1
            optional :discriminator, :string, 2
            optional :read_only, :bool, 3
            optional :external_docs, ExternalDocumentation, 5
            optional :example, :string, 6
          end
        end
        
        struct EnumSchema
          include ::Protobuf::Message
          
          struct ExtensionsEntry
            include ::Protobuf::Message
            
            contract_of "proto3" do
              optional :key, :string, 1
              optional :value, Google::Protobuf::Value, 2
            end
          end
          
          contract_of "proto3" do
            optional :description, :string, 1
            optional :default, :string, 2
            optional :title, :string, 3
            optional :required, :bool, 4
            optional :read_only, :bool, 5
            optional :external_docs, ExternalDocumentation, 6
            optional :example, :string, 7
            optional :ref, :string, 8
            repeated :extensions, EnumSchema::ExtensionsEntry, 9
          end
        end
        
        struct JSONSchema
          include ::Protobuf::Message
          enum JSONSchemaSimpleTypes
            UNKNOWN = 0
            ARRAY = 1
            BOOLEAN = 2
            INTEGER = 3
            NULL = 4
            NUMBER = 5
            OBJECT = 6
            STRING = 7
          end
          
          struct FieldConfiguration
            include ::Protobuf::Message
            
            contract_of "proto3" do
              optional :path_param_name, :string, 47
            end
          end
          
          struct ExtensionsEntry
            include ::Protobuf::Message
            
            contract_of "proto3" do
              optional :key, :string, 1
              optional :value, Google::Protobuf::Value, 2
            end
          end
          
          contract_of "proto3" do
            optional :ref, :string, 3
            optional :title, :string, 5
            optional :description, :string, 6
            optional :default, :string, 7
            optional :read_only, :bool, 8
            optional :example, :string, 9
            optional :multiple_of, :double, 10
            optional :maximum, :double, 11
            optional :exclusive_maximum, :bool, 12
            optional :minimum, :double, 13
            optional :exclusive_minimum, :bool, 14
            optional :max_length, :uint64, 15
            optional :min_length, :uint64, 16
            optional :pattern, :string, 17
            optional :max_items, :uint64, 20
            optional :min_items, :uint64, 21
            optional :unique_items, :bool, 22
            optional :max_properties, :uint64, 24
            optional :min_properties, :uint64, 25
            repeated :required, :string, 26
            repeated :array, :string, 34
            repeated :type, JSONSchema::JSONSchemaSimpleTypes, 35
            optional :format, :string, 36
            repeated :enum, :string, 46
            optional :field_configuration, JSONSchema::FieldConfiguration, 1001
            repeated :extensions, JSONSchema::ExtensionsEntry, 48
          end
        end
        
        struct Tag
          include ::Protobuf::Message
          
          struct ExtensionsEntry
            include ::Protobuf::Message
            
            contract_of "proto3" do
              optional :key, :string, 1
              optional :value, Google::Protobuf::Value, 2
            end
          end
          
          contract_of "proto3" do
            optional :name, :string, 1
            optional :description, :string, 2
            optional :external_docs, ExternalDocumentation, 3
            repeated :extensions, Tag::ExtensionsEntry, 4
          end
        end
        
        struct SecurityDefinitions
          include ::Protobuf::Message
          
          struct SecurityEntry
            include ::Protobuf::Message
            
            contract_of "proto3" do
              optional :key, :string, 1
              optional :value, SecurityScheme, 2
            end
          end
          
          contract_of "proto3" do
            repeated :security, SecurityDefinitions::SecurityEntry, 1
          end
        end
        
        struct SecurityScheme
          include ::Protobuf::Message
          enum Type
            INVALID = 0
            TYPEINVALID = 0
            BASIC = 1
            TYPEBASIC = 1
            API_KEY = 2
            TYPEAPIKEY = 2
            OAUTH2 = 3
            TYPEOAUTH2 = 3
          end
          enum In
            INVALID = 0
            ININVALID = 0
            QUERY = 1
            INQUERY = 1
            HEADER = 2
            INHEADER = 2
          end
          enum Flow
            INVALID = 0
            FLOWINVALID = 0
            IMPLICIT = 1
            FLOWIMPLICIT = 1
            PASSWORD = 2
            FLOWPASSWORD = 2
            APPLICATION = 3
            FLOWAPPLICATION = 3
            ACCESS_CODE = 4
            FLOWACCESSCODE = 4
          end
          
          struct ExtensionsEntry
            include ::Protobuf::Message
            
            contract_of "proto3" do
              optional :key, :string, 1
              optional :value, Google::Protobuf::Value, 2
            end
          end
          
          contract_of "proto3" do
            optional :type, SecurityScheme::Type, 1
            optional :description, :string, 2
            optional :name, :string, 3
            optional :in, SecurityScheme::In, 4
            optional :flow, SecurityScheme::Flow, 5
            optional :authorization_url, :string, 6
            optional :token_url, :string, 7
            optional :scopes, Scopes, 8
            repeated :extensions, SecurityScheme::ExtensionsEntry, 9
          end
        end
        
        struct SecurityRequirement
          include ::Protobuf::Message
          
          struct SecurityRequirementValue
            include ::Protobuf::Message
            
            contract_of "proto3" do
              repeated :scope, :string, 1
            end
          end
          
          struct SecurityRequirementEntry
            include ::Protobuf::Message
            
            contract_of "proto3" do
              optional :key, :string, 1
              optional :value, SecurityRequirement::SecurityRequirementValue, 2
            end
          end
          
          contract_of "proto3" do
            repeated :security_requirement, SecurityRequirement::SecurityRequirementEntry, 1
          end
        end
        
        struct Scopes
          include ::Protobuf::Message
          
          struct ScopeEntry
            include ::Protobuf::Message
            
            contract_of "proto3" do
              optional :key, :string, 1
              optional :value, :string, 2
            end
          end
          
          contract_of "proto3" do
            repeated :scope, Scopes::ScopeEntry, 1
          end
        end
        end
      end
    end
  end
