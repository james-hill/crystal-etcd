require "./model/maintenance"

class Etcd::Maintenance
  getter stub : Etcdserverpb::Maintenance::Stub

  def initialize(config : GRPC::Config)
    @stub = Etcdserverpb::Maintenance::Stub.new(config)
  end

  def alarm(action : Model::AlarmAction, alarm : Model::AlarmType? = nil, member_id : UInt64? = nil)
    request = Etcdserverpb::AlarmRequest.new(action: action.to_grpc)
    if type = alarm
      request.alarm = type.to_grpc
    end

    if mid = member_id
      request.member_id = mid
    end

    (stub.alarm(request).alarms || [] of Etcdserverpb::AlarmMember).map do |alarm|
      if type = alarm.alarm
        Model::Alarm.new(
          alarm: Model::AlarmType.from_grpc(type),
          member_id: alarm.member_id,
        )
      else
        raise "Alarm has no type"
      end
    end
  end

  def defragment
    stub.defragment(Etcdserverpb::DefragmentRequest.new).is_a?(Etcdserverpb::DefragmentResponse)
  end

  def hash(revision : String)
    stub.hash(::Etcdserverpb::HashRequest.new).hash
  end

  # TODO: this deadlocks currently
  def snapshot
    response = stub.snapshot(Etcdserverpb::SnapshotRequest.new)
    if blob = response.blob
      Model::SnapshotResult.new(
        blob: blob,
        remaining_bytes: response.remaining_bytes || 0_u64,
        version: response.version,
      )
    else
      raise "No blob in response"
    end
  end

  # Queries status of etcd instance
  def status
    response = stub.status(Etcdserverpb::StatusRequest.new)

    Model::Status.new(
      db_size: response.db_size,
      db_size_in_use: response.db_size_in_use,
      errors: response.errors,
      is_learner: response.is_learner,
      leader: response.leader,
      raft_applied_index: response.raft_applied_index,
      raft_index: response.raft_index,
      raft_term: response.raft_term,
      version: response.version,
    )
  end

  # Queries for current leader of the etcd cluster
  def leader
    status.leader
  end

  def transfer_leadership(target_id : UInt64)
    stub.move_leadership(Etcdserverpb::MoveLeaderRequest.new(targetID: target_id)).is_a?(Etcdserverpb::MoveLeaderResponse)
  end
end
