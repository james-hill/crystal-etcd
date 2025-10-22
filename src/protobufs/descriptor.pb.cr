## Generated from google/protobuf/descriptor.proto for google.protobuf
require "protobuf"

module Google
  module Protobuf
    enum Edition
      UNKNOWN = 0
      EDITIONUNKNOWN = 0
      LEGACY = 900
      EDITIONLEGACY = 900
      PROTO2 = 998
      EDITIONPROTO2 = 998
      PROTO3 = 999
      EDITIONPROTO3 = 999
      EDITION2023 = 1000
      EDITION2024 = 1001
      EDITION1TESTONLY = 1
      EDITION2TESTONLY = 2
      EDITION99997TESTONLY = 99997
      EDITION99998TESTONLY = 99998
      EDITION99999TESTONLY = 99999
      MAX = 2147483647
      EDITIONMAX = 2147483647
    end
    enum SymbolVisibility
      VISIBILITY_UNSET = 0
      VISIBILITYUNSET = 0
      VISIBILITY_LOCAL = 1
      VISIBILITYLOCAL = 1
      VISIBILITY_EXPORT = 2
      VISIBILITYEXPORT = 2
    end
    
    struct FileDescriptorSet
      include ::Protobuf::Message
      
      contract_of "proto2" do
        repeated :file, FileDescriptorProto, 1
      end
    end
    
    struct FileDescriptorProto
      include ::Protobuf::Message
      
      contract_of "proto2" do
        optional :name, :string, 1
        optional :package, :string, 2
        repeated :dependency, :string, 3
        repeated :public_dependency, :int32, 10
        repeated :weak_dependency, :int32, 11
        repeated :option_dependency, :string, 15
        repeated :message_type, DescriptorProto, 4
        repeated :enum_type, EnumDescriptorProto, 5
        repeated :service, ServiceDescriptorProto, 6
        repeated :extension, FieldDescriptorProto, 7
        optional :options, FileOptions, 8
        optional :source_code_info, SourceCodeInfo, 9
        optional :syntax, :string, 12
        optional :edition, Edition, 14
      end
    end
    
    class DescriptorProto
      include ::Protobuf::Message
      
      struct ExtensionRange
        include ::Protobuf::Message
        
        contract_of "proto2" do
          optional :start, :int32, 1
          optional :end, :int32, 2
          optional :options, ExtensionRangeOptions, 3
        end
      end
      
      struct ReservedRange
        include ::Protobuf::Message
        
        contract_of "proto2" do
          optional :start, :int32, 1
          optional :end, :int32, 2
        end
      end
      
      contract_of "proto2" do
        optional :name, :string, 1
        repeated :field, FieldDescriptorProto, 2
        repeated :extension, FieldDescriptorProto, 6
        repeated :nested_type, DescriptorProto, 3
        repeated :enum_type, EnumDescriptorProto, 4
        repeated :extension_range, DescriptorProto::ExtensionRange, 5
        repeated :oneof_decl, OneofDescriptorProto, 8
        optional :options, MessageOptions, 7
        repeated :reserved_range, DescriptorProto::ReservedRange, 9
        repeated :reserved_name, :string, 10
        optional :visibility, SymbolVisibility, 11
      end
    end
    
    struct ExtensionRangeOptions
      include ::Protobuf::Message
      enum VerificationState
        DECLARATION = 0
        UNVERIFIED = 1
      end
      
      struct Declaration
        include ::Protobuf::Message
        
        contract_of "proto2" do
          optional :number, :int32, 1
          optional :full_name, :string, 2
          optional :type, :string, 3
          optional :reserved, :bool, 5
          optional :repeated, :bool, 6
        end
      end
      
      contract_of "proto2" do
        repeated :uninterpreted_option, UninterpretedOption, 999
        repeated :declaration, ExtensionRangeOptions::Declaration, 2
        optional :features, FeatureSet, 50
        optional :verification, ExtensionRangeOptions::VerificationState, 3, default: ExtensionRangeOptions::VerificationState::UNVERIFIED
      end
    end
    
    struct FieldDescriptorProto
      include ::Protobuf::Message
      enum Type
        DOUBLE = 1
        TYPEDOUBLE = 1
        FLOAT = 2
        TYPEFLOAT = 2
        INT64 = 3
        TYPEINT64 = 3
        UINT64 = 4
        TYPEUINT64 = 4
        INT32 = 5
        TYPEINT32 = 5
        FIXED64 = 6
        TYPEFIXED64 = 6
        FIXED32 = 7
        TYPEFIXED32 = 7
        BOOL = 8
        TYPEBOOL = 8
        STRING = 9
        TYPESTRING = 9
        GROUP = 10
        TYPEGROUP = 10
        MESSAGE = 11
        TYPEMESSAGE = 11
        BYTES = 12
        TYPEBYTES = 12
        UINT32 = 13
        TYPEUINT32 = 13
        ENUM = 14
        TYPEENUM = 14
        SFIXED32 = 15
        TYPESFIXED32 = 15
        SFIXED64 = 16
        TYPESFIXED64 = 16
        SINT32 = 17
        TYPESINT32 = 17
        SINT64 = 18
        TYPESINT64 = 18
      end
      enum Label
        OPTIONAL = 1
        LABELOPTIONAL = 1
        REPEATED = 3
        LABELREPEATED = 3
        REQUIRED = 2
        LABELREQUIRED = 2
      end
      
      contract_of "proto2" do
        optional :name, :string, 1
        optional :number, :int32, 3
        optional :label, FieldDescriptorProto::Label, 4
        optional :type, FieldDescriptorProto::Type, 5
        optional :type_name, :string, 6
        optional :extendee, :string, 2
        optional :default_value, :string, 7
        optional :oneof_index, :int32, 9
        optional :json_name, :string, 10
        optional :options, FieldOptions, 8
        optional :proto3_optional, :bool, 17
      end
    end
    
    struct OneofDescriptorProto
      include ::Protobuf::Message
      
      contract_of "proto2" do
        optional :name, :string, 1
        optional :options, OneofOptions, 2
      end
    end
    
    struct EnumDescriptorProto
      include ::Protobuf::Message
      
      struct EnumReservedRange
        include ::Protobuf::Message
        
        contract_of "proto2" do
          optional :start, :int32, 1
          optional :end, :int32, 2
        end
      end
      
      contract_of "proto2" do
        optional :name, :string, 1
        repeated :value, EnumValueDescriptorProto, 2
        optional :options, EnumOptions, 3
        repeated :reserved_range, EnumDescriptorProto::EnumReservedRange, 4
        repeated :reserved_name, :string, 5
        optional :visibility, SymbolVisibility, 6
      end
    end
    
    struct EnumValueDescriptorProto
      include ::Protobuf::Message
      
      contract_of "proto2" do
        optional :name, :string, 1
        optional :number, :int32, 2
        optional :options, EnumValueOptions, 3
      end
    end
    
    struct ServiceDescriptorProto
      include ::Protobuf::Message
      
      contract_of "proto2" do
        optional :name, :string, 1
        repeated :method, MethodDescriptorProto, 2
        optional :options, ServiceOptions, 3
      end
    end
    
    struct MethodDescriptorProto
      include ::Protobuf::Message
      
      contract_of "proto2" do
        optional :name, :string, 1
        optional :input_type, :string, 2
        optional :output_type, :string, 3
        optional :options, MethodOptions, 4
        optional :client_streaming, :bool, 5, default: false
        optional :server_streaming, :bool, 6, default: false
      end
    end
    
    struct FileOptions
      include ::Protobuf::Message
      enum OptimizeMode
        SPEED = 1
        CODE_SIZE = 2
        CODESIZE = 2
        LITE_RUNTIME = 3
        LITERUNTIME = 3
      end
      
      contract_of "proto2" do
        optional :java_package, :string, 1
        optional :java_outer_classname, :string, 8
        optional :java_multiple_files, :bool, 10, default: false
        optional :java_generate_equals_and_hash, :bool, 20
        optional :java_string_check_utf8, :bool, 27, default: false
        optional :optimize_for, FileOptions::OptimizeMode, 9, default: FileOptions::OptimizeMode::SPEED
        optional :go_package, :string, 11
        optional :cc_generic_services, :bool, 16, default: false
        optional :java_generic_services, :bool, 17, default: false
        optional :py_generic_services, :bool, 18, default: false
        optional :deprecated, :bool, 23, default: false
        optional :cc_enable_arenas, :bool, 31, default: true
        optional :objc_class_prefix, :string, 36
        optional :csharp_namespace, :string, 37
        optional :swift_prefix, :string, 39
        optional :php_class_prefix, :string, 40
        optional :php_namespace, :string, 41
        optional :php_metadata_namespace, :string, 44
        optional :ruby_package, :string, 45
        optional :features, FeatureSet, 50
        repeated :uninterpreted_option, UninterpretedOption, 999
      end
    end
    
    struct MessageOptions
      include ::Protobuf::Message
      
      contract_of "proto2" do
        optional :message_set_wire_format, :bool, 1, default: false
        optional :no_standard_descriptor_accessor, :bool, 2, default: false
        optional :deprecated, :bool, 3, default: false
        optional :map_entry, :bool, 7
        optional :deprecated_legacy_json_field_conflicts, :bool, 11
        optional :features, FeatureSet, 12
        repeated :uninterpreted_option, UninterpretedOption, 999
      end
    end
    
    struct FieldOptions
      include ::Protobuf::Message
      enum CType
        STRING = 0
        CORD = 1
        STRING_PIECE = 2
        STRINGPIECE = 2
      end
      enum JSType
        JS_NORMAL = 0
        JSNORMAL = 0
        JS_STRING = 1
        JSSTRING = 1
        JS_NUMBER = 2
        JSNUMBER = 2
      end
      enum OptionRetention
        RETENTION_UNKNOWN = 0
        RETENTIONUNKNOWN = 0
        RETENTION_RUNTIME = 1
        RETENTIONRUNTIME = 1
        RETENTION_SOURCE = 2
        RETENTIONSOURCE = 2
      end
      enum OptionTargetType
        TARGET_TYPE_UNKNOWN = 0
        TARGETTYPEUNKNOWN = 0
        TARGET_TYPE_FILE = 1
        TARGETTYPEFILE = 1
        TARGET_TYPE_EXTENSION_RANGE = 2
        TARGETTYPEEXTENSIONRANGE = 2
        TARGET_TYPE_MESSAGE = 3
        TARGETTYPEMESSAGE = 3
        TARGET_TYPE_FIELD = 4
        TARGETTYPEFIELD = 4
        TARGET_TYPE_ONEOF = 5
        TARGETTYPEONEOF = 5
        TARGET_TYPE_ENUM = 6
        TARGETTYPEENUM = 6
        TARGET_TYPE_ENUM_ENTRY = 7
        TARGETTYPEENUMENTRY = 7
        TARGET_TYPE_SERVICE = 8
        TARGETTYPESERVICE = 8
        TARGET_TYPE_METHOD = 9
        TARGETTYPEMETHOD = 9
      end
      
      struct EditionDefault
        include ::Protobuf::Message
        
        contract_of "proto2" do
          optional :edition, Edition, 3
          optional :value, :string, 2
        end
      end
      
      struct FeatureSupport
        include ::Protobuf::Message
        
        contract_of "proto2" do
          optional :edition_introduced, Edition, 1
          optional :edition_deprecated, Edition, 2
          optional :deprecation_warning, :string, 3
          optional :edition_removed, Edition, 4
        end
      end
      
      contract_of "proto2" do
        optional :ctype, FieldOptions::CType, 1, default: FieldOptions::CType::STRING
        optional :packed, :bool, 2
        optional :jstype, FieldOptions::JSType, 6, default: FieldOptions::JSType::JS_NORMAL
        optional :lazy, :bool, 5, default: false
        optional :unverified_lazy, :bool, 15, default: false
        optional :deprecated, :bool, 3, default: false
        optional :weak, :bool, 10, default: false
        optional :debug_redact, :bool, 16, default: false
        optional :retention, FieldOptions::OptionRetention, 17
        repeated :targets, FieldOptions::OptionTargetType, 19
        repeated :edition_defaults, FieldOptions::EditionDefault, 20
        optional :features, FeatureSet, 21
        optional :feature_support, FieldOptions::FeatureSupport, 22
        repeated :uninterpreted_option, UninterpretedOption, 999
      end
    end
    
    struct OneofOptions
      include ::Protobuf::Message
      
      contract_of "proto2" do
        optional :features, FeatureSet, 1
        repeated :uninterpreted_option, UninterpretedOption, 999
      end
    end
    
    struct EnumOptions
      include ::Protobuf::Message
      
      contract_of "proto2" do
        optional :allow_alias, :bool, 2
        optional :deprecated, :bool, 3, default: false
        optional :deprecated_legacy_json_field_conflicts, :bool, 6
        optional :features, FeatureSet, 7
        repeated :uninterpreted_option, UninterpretedOption, 999
      end
    end
    
    struct EnumValueOptions
      include ::Protobuf::Message
      
      contract_of "proto2" do
        optional :deprecated, :bool, 1, default: false
        optional :features, FeatureSet, 2
        optional :debug_redact, :bool, 3, default: false
        optional :feature_support, FieldOptions::FeatureSupport, 4
        repeated :uninterpreted_option, UninterpretedOption, 999
      end
    end
    
    struct ServiceOptions
      include ::Protobuf::Message
      
      contract_of "proto2" do
        optional :features, FeatureSet, 34
        optional :deprecated, :bool, 33, default: false
        repeated :uninterpreted_option, UninterpretedOption, 999
      end
    end
    
    struct MethodOptions
      include ::Protobuf::Message
      enum IdempotencyLevel
        IDEMPOTENCY_UNKNOWN = 0
        IDEMPOTENCYUNKNOWN = 0
        NO_SIDE_EFFECTS = 1
        NOSIDEEFFECTS = 1
        IDEMPOTENT = 2
      end
      
      contract_of "proto2" do
        optional :deprecated, :bool, 33, default: false
        optional :idempotency_level, MethodOptions::IdempotencyLevel, 34, default: MethodOptions::IdempotencyLevel::IDEMPOTENCY_UNKNOWN
        optional :features, FeatureSet, 35
        repeated :uninterpreted_option, UninterpretedOption, 999
      end
    end
    
    struct UninterpretedOption
      include ::Protobuf::Message
      
      struct NamePart
        include ::Protobuf::Message
        
        contract_of "proto2" do
          required :name_part, :string, 1
          required :is_extension, :bool, 2
        end
      end
      
      contract_of "proto2" do
        repeated :name, UninterpretedOption::NamePart, 2
        optional :identifier_value, :string, 3
        optional :positive_int_value, :uint64, 4
        optional :negative_int_value, :int64, 5
        optional :double_value, :double, 6
        optional :string_value, :bytes, 7
        optional :aggregate_value, :string, 8
      end
    end
    
    struct FeatureSet
      include ::Protobuf::Message
      enum FieldPresence
        UNKNOWN = 0
        FIELDPRESENCEUNKNOWN = 0
        EXPLICIT = 1
        IMPLICIT = 2
        LEGACY_REQUIRED = 3
        LEGACYREQUIRED = 3
      end
      enum EnumType
        UNKNOWN = 0
        ENUMTYPEUNKNOWN = 0
        OPEN = 1
        CLOSED = 2
      end
      enum RepeatedFieldEncoding
        UNKNOWN = 0
        REPEATEDFIELDENCODINGUNKNOWN = 0
        PACKED = 1
        EXPANDED = 2
      end
      enum Utf8Validation
        UNKNOWN = 0
        UTF8VALIDATIONUNKNOWN = 0
        VERIFY = 2
        NONE = 3
      end
      enum MessageEncoding
        UNKNOWN = 0
        MESSAGEENCODINGUNKNOWN = 0
        LENGTH_PREFIXED = 1
        LENGTHPREFIXED = 1
        DELIMITED = 2
      end
      enum JsonFormat
        UNKNOWN = 0
        JSONFORMATUNKNOWN = 0
        ALLOW = 1
        LEGACY_BEST_EFFORT = 2
        LEGACYBESTEFFORT = 2
      end
      enum EnforceNamingStyle
        UNKNOWN = 0
        ENFORCENAMINGSTYLEUNKNOWN = 0
        STYLE2024 = 1
        STYLE_LEGACY = 2
        STYLELEGACY = 2
      end
      
      struct VisibilityFeature
        include ::Protobuf::Message
        enum DefaultSymbolVisibility
          UNKNOWN = 0
          DEFAULTSYMBOLVISIBILITYUNKNOWN = 0
          EXPORT_ALL = 1
          EXPORTALL = 1
          EXPORT_TOP_LEVEL = 2
          EXPORTTOPLEVEL = 2
          LOCAL_ALL = 3
          LOCALALL = 3
          STRICT = 4
        end
        
        contract_of "proto2" do
        end
      end
      
      contract_of "proto2" do
        optional :field_presence, FeatureSet::FieldPresence, 1
        optional :enum_type, FeatureSet::EnumType, 2
        optional :repeated_field_encoding, FeatureSet::RepeatedFieldEncoding, 3
        optional :utf8_validation, FeatureSet::Utf8Validation, 4
        optional :message_encoding, FeatureSet::MessageEncoding, 5
        optional :json_format, FeatureSet::JsonFormat, 6
        optional :enforce_naming_style, FeatureSet::EnforceNamingStyle, 7
        optional :default_symbol_visibility, FeatureSet::VisibilityFeature::DefaultSymbolVisibility, 8
      end
    end
    
    struct FeatureSetDefaults
      include ::Protobuf::Message
      
      struct FeatureSetEditionDefault
        include ::Protobuf::Message
        
        contract_of "proto2" do
          optional :edition, Edition, 3
          optional :overridable_features, FeatureSet, 4
          optional :fixed_features, FeatureSet, 5
        end
      end
      
      contract_of "proto2" do
        repeated :defaults, FeatureSetDefaults::FeatureSetEditionDefault, 1
        optional :minimum_edition, Edition, 4
        optional :maximum_edition, Edition, 5
      end
    end
    
    struct SourceCodeInfo
      include ::Protobuf::Message
      
      struct Location
        include ::Protobuf::Message
        
        contract_of "proto2" do
          repeated :path, :int32, 1, packed: true
          repeated :span, :int32, 2, packed: true
          optional :leading_comments, :string, 3
          optional :trailing_comments, :string, 4
          repeated :leading_detached_comments, :string, 6
        end
      end
      
      contract_of "proto2" do
        repeated :location, SourceCodeInfo::Location, 1
      end
    end
    
    struct GeneratedCodeInfo
      include ::Protobuf::Message
      
      struct Annotation
        include ::Protobuf::Message
        enum Semantic
          NONE = 0
          SET = 1
          ALIAS = 2
        end
        
        contract_of "proto2" do
          repeated :path, :int32, 1, packed: true
          optional :source_file, :string, 2
          optional :begin, :int32, 3
          optional :end, :int32, 4
          optional :semantic, GeneratedCodeInfo::Annotation::Semantic, 5
        end
      end
      
      contract_of "proto2" do
        repeated :annotation, GeneratedCodeInfo::Annotation, 1
      end
    end
    end
  end
