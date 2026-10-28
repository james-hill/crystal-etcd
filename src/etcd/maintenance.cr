require "./model/maintenance"
require "./message_buffer"

class Etcd::Maintenance
  getter stub : Etcdserverpb::Maintenance::Stub

  def initialize(@api : Etcd::Api)
    @stub = Etcdserverpb::Maintenance::Stub.new(@api.config)
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

  # Hash of the whole backend, including key history
  def hash : UInt32?
    stub.hash(Etcdserverpb::HashRequest.new).hash
  end

  # Hash of the key-value state as of `revision` (0 means the current revision)
  def hash_kv(revision : Int64 = 0_i64) : Model::HashKv
    Model::HashKv.from_grpc(stub.hash_kv(Etcdserverpb::HashKVRequest.new(revision: revision)))
  end

  # Streams a backend snapshot, yielding each chunk's bytes and the bytes etcd still has to send.
  #
  # etcd ends the stream with an integrity hash (sha256 of the data, padded to 512 bytes), which
  # `etcdctl snapshot restore` expects at the end of the file, so keep every chunk.
  def snapshot(& : Bytes, UInt64 ->) : Nil
    http2 = @api.config.http2
    raise Etcd::ConnectionError.new if http2.nil? || http2.closed?

    headers = HTTP::Headers{
      ":method"      => "POST",
      ":path"        => "/etcdserverpb.Maintenance/Snapshot",
      "content-type" => "application/grpc",
    }
    channel = http2.open_stream(headers, data: GRPC.encode_protobuf(Etcdserverpb::SnapshotRequest.new))
    messages = MessageBuffer(Etcdserverpb::SnapshotResponse).new

    chunks = 0
    data_done = false
    while payload = channel.receive?
      messages << payload
      while response = messages.next_message
        chunks += 1
        remaining = response.remaining_bytes || 0_u64
        yield (response.blob || Bytes.empty), remaining

        # The hash chunk follows the last data chunk; the server closes the stream after it
        return if data_done
        data_done = remaining.zero?
      end
    end

    raise Etcd::Error.new "Snapshot stream closed before etcd sent any data" if chunks.zero?
  end

  # Writes a backend snapshot to `io`, returning the number of bytes written
  def snapshot(io : IO) : Int64
    written = 0_i64
    snapshot do |blob, _remaining|
      io.write(blob)
      written += blob.size
    end
    written
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

  # Asks the current leader to hand leadership to member `target_id`
  def transfer_leadership(target_id : UInt64) : Bool
    stub.move_leader(Etcdserverpb::MoveLeaderRequest.new(target_id: target_id)).is_a?(Etcdserverpb::MoveLeaderResponse)
  end
end
