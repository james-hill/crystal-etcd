require "./base"

module Etcd::Model
  alias GrpcAlarmAction = Etcdserverpb::AlarmRequest::AlarmAction
  alias GrpcAlarmType = Etcdserverpb::AlarmType

  enum AlarmAction
    GET
    ACTIVATE
    DEACTIVATE

    def self.from_grpc(type : GrpcAlarmAction)
      case type
      when .get?
        GET
      when .activate?
        ACTIVATE
      when .deactivate?
        DEACTIVATE
      else
        raise "Unknown alarm action: #{type}"
      end
    end

    def to_grpc
      case self
      when .get?
        GrpcAlarmAction::GET
      when .activate?
        GrpcAlarmAction::ACTIVATE
      when .deactivate?
        GrpcAlarmAction::DEACTIVATE
      else
        raise "Unknown alarm action: #{self}"
      end
    end
  end

  enum AlarmType
    NONE
    NOSPACE
    CORRUPT

    def self.from_grpc(type : GrpcAlarmType)
      case type
      when .none?
        NONE
      when .nospace?
        NOSPACE
      when .corrupt?
        CORRUPT
      else
        raise "Unknown alarm type: #{type}"
      end
    end

    def to_grpc
      case self
      when .none?
        GrpcAlarmType::NONE
      when .nospace?
        GrpcAlarmType::NOSPACE
      when .corrupt?
        GrpcAlarmType::CORRUPT
      else
        raise "Unknown alarm type: #{self}"
      end
    end
  end

  struct Alarm
    getter! alarm : AlarmType
    getter! member_id : UInt64

    def initialize(@alarm, @member_id)
    end
  end

  struct HashKv
    getter hash : UInt32
    getter compact_revision : Int64
    getter hash_revision : Int64

    def self.from_grpc(response : Etcdserverpb::HashKVResponse)
      new(
        hash: response.hash || 0_u32,
        compact_revision: response.compact_revision || 0_i64,
        hash_revision: response.hash_revision || 0_i64,
      )
    end

    def initialize(@hash, @compact_revision, @hash_revision)
    end
  end

  struct Status
    getter! db_size : Int64
    getter! db_size_in_use : Int64
    getter errors : Array(String)
    getter is_learner : Bool
    getter! leader : UInt64
    getter! raft_applied_index : UInt64
    getter! raft_index : UInt64
    getter! raft_term : UInt64
    getter! version : String

    # etcd leaves `errors` and `is_learner` unset when there is nothing to report
    def initialize(@db_size, @db_size_in_use, errors : Array(String)?, is_learner : Bool?, @leader, @raft_applied_index, @raft_index, @raft_term, @version)
      @errors = errors || [] of String
      @is_learner = is_learner || false
    end
  end
end
