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

  struct SnapshotResult
    getter blob : Bytes # Bytes
    getter remaining_bytes : UInt64
    getter version : String

    def initialize(@blob, @remaining_bytes, @version)
    end
  end

  struct Status
    getter! db_size : Int64
    getter! db_size_in_use : Int64
    getter! errors : Array(String)?
    getter! is_learner : Bool?
    getter! leader : UInt64
    getter! raft_applied_index : UInt64
    getter! raft_index : UInt64
    getter! raft_term : UInt64
    getter! version : String

    def initialize(@db_size, @db_size_in_use, @errors, @is_learner, @leader, @raft_applied_index, @raft_index, @raft_term, @version)
    end
  end
end
