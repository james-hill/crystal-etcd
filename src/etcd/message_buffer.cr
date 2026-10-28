require "./error"

module Etcd
  # Reassembles gRPC length-prefixed messages of type `T` from HTTP/2 DATA payloads.
  #
  # A payload is whatever bytes arrived on the stream: one message can span several
  # payloads and one payload can carry several messages, so decode only once a whole
  # message is buffered.
  class MessageBuffer(T)
    # Compression flag (1 byte) + big-endian length (4 bytes)
    HEADER_BYTES = 5

    # No etcd stream message is this large; a bigger length is a framing error
    MAX_MESSAGE_BYTES = 64 * 1024 * 1024

    @buffer = Bytes.empty

    def <<(payload : Bytes) : self
      return self if payload.empty?

      if @buffer.empty?
        @buffer = payload
      else
        joined = Bytes.new(@buffer.size + payload.size)
        joined.copy_from(@buffer)
        (joined + @buffer.size).copy_from(payload)
        @buffer = joined
      end

      self
    end

    # The next complete message, or nil until more bytes arrive
    def next_message : T?
      return nil if @buffer.size < HEADER_BYTES

      length = IO::ByteFormat::BigEndian.decode(Int32, @buffer[1, 4])
      if length < 0 || length > MAX_MESSAGE_BYTES
        raise Etcd::FramingError.new "Impossible gRPC message length #{length}; the stream is out of sync"
      end

      total = HEADER_BYTES + length
      return nil if @buffer.size < total

      message = @buffer[HEADER_BYTES, length]
      @buffer = @buffer + total
      T.from_protobuf(IO::Memory.new(message))
    end

    def pending_bytes : Int32
      @buffer.size
    end
  end
end
