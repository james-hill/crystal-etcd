require "./helper"

module Etcd
  module FramingSpec
    extend self

    def response(revision : Int64, key : String) : Etcdserverpb::WatchResponse
      Etcdserverpb::WatchResponse.new(
        header: Etcdserverpb::ResponseHeader.new(revision: revision),
        watch_id: 7_i64,
        events: [
          Mvccpb::Event.new(
            type: Mvccpb::Event::EventType::PUT,
            kv: Mvccpb::KeyValue.new(key: key.to_slice, value: "v#{revision}".to_slice, mod_revision: revision),
          ),
        ],
      )
    end

    def encoded(revision : Int64, key : String = "#{TEST_PREFIX}/k") : Bytes
      GRPC.encode_protobuf(response(revision, key))
    end

    def drain(buffer : Watch::MessageBuffer) : Array(Etcdserverpb::WatchResponse)
      messages = [] of Etcdserverpb::WatchResponse
      while message = buffer.next_message
        messages << message
      end
      messages
    end
  end

  describe Watch::MessageBuffer do
    it "decodes a message that arrived in one payload" do
      buffer = Watch::MessageBuffer.new
      buffer << FramingSpec.encoded(10_i64)

      messages = FramingSpec.drain(buffer)
      messages.size.should eq 1
      messages.first.header.try(&.revision).should eq 10_i64
      messages.first.events.try(&.first.kv.try(&.value)).should eq "v10".to_slice
      buffer.pending_bytes.should eq 0
    end

    it "reassembles a message split across several payloads" do
      bytes = FramingSpec.encoded(11_i64, "#{TEST_PREFIX}/#{"x" * 5000}")
      buffer = Watch::MessageBuffer.new

      # Split inside the length prefix, then into uneven chunks
      cuts = [3, 700, 2048, bytes.size]
      start = 0
      cuts.each do |stop|
        buffer << bytes[start, stop - start]
        if stop < bytes.size
          buffer.next_message.should be_nil
        end
        start = stop
      end

      messages = FramingSpec.drain(buffer)
      messages.size.should eq 1
      messages.first.header.try(&.revision).should eq 11_i64
      messages.first.events.try(&.first.kv.try(&.key.try(&.size))).should eq TEST_PREFIX.size + 1 + 5000
    end

    it "decodes several messages carried by one payload" do
      joined = IO::Memory.new
      joined.write FramingSpec.encoded(20_i64)
      joined.write FramingSpec.encoded(21_i64)
      joined.write FramingSpec.encoded(22_i64)

      buffer = Watch::MessageBuffer.new
      buffer << joined.to_slice

      FramingSpec.drain(buffer).map(&.header.try(&.revision)).should eq [20_i64, 21_i64, 22_i64]
      buffer.pending_bytes.should eq 0
    end

    it "keeps a trailing partial message until the rest arrives" do
      first = FramingSpec.encoded(30_i64)
      second = FramingSpec.encoded(31_i64)
      split = second.size // 2

      payload = IO::Memory.new
      payload.write first
      payload.write second[0, split]

      buffer = Watch::MessageBuffer.new
      buffer << payload.to_slice

      FramingSpec.drain(buffer).map(&.header.try(&.revision)).should eq [30_i64]
      buffer.pending_bytes.should eq split

      buffer << second + split
      FramingSpec.drain(buffer).map(&.header.try(&.revision)).should eq [31_i64]
      buffer.pending_bytes.should eq 0
    end

    it "ignores empty payloads" do
      buffer = Watch::MessageBuffer.new
      buffer << Bytes.empty
      buffer.next_message.should be_nil
      buffer.pending_bytes.should eq 0
    end

    it "raises on a length that can only be a framing error" do
      header = IO::Memory.new
      header.write_bytes(0_u8)
      header.write_bytes(Watch::MessageBuffer::MAX_MESSAGE_BYTES + 1, IO::ByteFormat::BigEndian)

      buffer = Watch::MessageBuffer.new
      buffer << header.to_slice

      expect_raises(Etcd::FramingError, /Impossible gRPC message length/) do
        buffer.next_message
      end
    end

    it "raises on a negative length" do
      header = IO::Memory.new
      header.write_bytes(0_u8)
      header.write_bytes(-1_i32, IO::ByteFormat::BigEndian)

      buffer = Watch::MessageBuffer.new
      buffer << header.to_slice

      expect_raises(Etcd::FramingError) do
        buffer.next_message
      end
    end
  end
end
