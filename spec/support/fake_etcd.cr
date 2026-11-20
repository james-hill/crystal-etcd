require "socket"
require "http2"

# A raw HTTP/2 gRPC server standing in for an etcd member. Each request it reads in full is
# recorded, then the spec's handler decides what happens to it.
class FakeEtcd
  # What the server does with a request it has read
  enum Action
    Answer    # answer with the handler's message
    Drop      # close the connection without answering
    Hang      # never answer
    Refuse    # answer UNAUTHENTICATED
    Compacted # answer OUT_OF_RANGE, as etcd does for a revision already compacted
  end

  record Request, path : String, headers : HTTP::Headers, body : Bytes, connection : Int32 do
    def method_name : String
      path.split('/').last
    end
  end

  alias Handler = Request -> {Action, Protobuf::Message?}

  getter requests = [] of Request
  getter connections = 0
  @server : TCPServer
  @clients = [] of TCPSocket

  def initialize(&@handler : Handler)
    @server = TCPServer.new("127.0.0.1", 0)
    spawn accept_loop
  end

  def port : Int32
    @server.local_address.port
  end

  def url : URI
    URI.parse("http://127.0.0.1:#{port}")
  end

  def calls(method_name : String) : Int32
    requests.count { |request| request.method_name == method_name }
  end

  def close
    @server.close rescue nil
    @clients.each { |client| client.close rescue nil }
  end

  private def accept_loop
    while socket = @server.accept?
      @connections += 1
      @clients << socket
      spawn serve(socket, @connections)
    end
  end

  private def serve(io : TCPSocket, connection : Int32)
    preface = Bytes.new(24)
    io.read_fully(preface)
    write_frame(io, HTTP2::Frame::Type::SETTINGS, 0_u8, 0, Bytes.empty)

    decoder = HTTP2::HPACK::Decoder.new
    encoder = HTTP2::HPACK::Encoder.new
    pending = {} of Int32 => {HTTP::Headers, IO::Memory}

    while frame = read_frame(io)
      type, flags, stream_id, payload = frame
      case type
      when HTTP2::Frame::Type::SETTINGS
        write_frame(io, HTTP2::Frame::Type::SETTINGS, 1_u8, 0, Bytes.empty) unless flags & 1 == 1
      when HTTP2::Frame::Type::HEADERS
        pending[stream_id] = {decoder.decode(payload), IO::Memory.new}
      when HTTP2::Frame::Type::DATA
        if entry = pending[stream_id]?
          entry[1].write(payload)
        end
      end

      next unless type.in?(HTTP2::Frame::Type::HEADERS, HTTP2::Frame::Type::DATA) && flags & 1 == 1
      next unless entry = pending.delete(stream_id)

      headers, body = entry
      request = Request.new(headers[":path"], headers, grpc_message(body.to_slice), connection)
      @requests << request
      action, message = @handler.call(request)
      case action
      in .answer?
        answer(io, encoder, stream_id, message)
      in .drop?
        io.close
        return
      in .hang?
      in .refuse?
        fail_with(io, encoder, stream_id, GRPC::StatusCode::UNAUTHENTICATED, "invalid auth token")
      in .compacted?
        fail_with(io, encoder, stream_id, GRPC::StatusCode::OUT_OF_RANGE, "mvcc: required revision has been compacted")
      end
    end
  rescue IO::Error
  end

  # A trailers-only gRPC error
  private def fail_with(io, encoder, stream_id, code : GRPC::StatusCode, message : String)
    trailers = HTTP::Headers{":status" => "200", "content-type" => "application/grpc", "grpc-status" => code.value.to_s, "grpc-message" => message}
    write_frame(io, HTTP2::Frame::Type::HEADERS, 0x5_u8, stream_id, encoder.encode(trailers))
  end

  private def answer(io, encoder, stream_id, message)
    body = message.try { |m| GRPC.encode_protobuf(m) } || Bytes[0, 0, 0, 0, 0]
    write_frame(io, HTTP2::Frame::Type::HEADERS, 0x4_u8, stream_id, encoder.encode(HTTP::Headers{":status" => "200", "content-type" => "application/grpc"}))
    write_frame(io, HTTP2::Frame::Type::DATA, 0_u8, stream_id, body)
    write_frame(io, HTTP2::Frame::Type::HEADERS, 0x5_u8, stream_id, encoder.encode(HTTP::Headers{"grpc-status" => "0"}))
  end

  # The protobuf payload of a single length-prefixed gRPC message
  private def grpc_message(bytes : Bytes) : Bytes
    bytes.size < 5 ? Bytes.empty : bytes[5..]
  end

  private def read_frame(io) : {HTTP2::Frame::Type, UInt8, Int32, Bytes}?
    header = Bytes.new(9)
    return if io.read_fully?(header).nil?
    length = (header[0].to_i32 << 16) | (header[1].to_i32 << 8) | header[2].to_i32
    stream_id = IO::ByteFormat::BigEndian.decode(UInt32, header[5, 4]).to_i32 & 0x7fffffff
    payload = Bytes.new(length)
    io.read_fully(payload)
    {HTTP2::Frame::Type.new(header[3].to_i32), header[4], stream_id, payload}
  end

  private def write_frame(io, type : HTTP2::Frame::Type, flags : UInt8, stream_id : Int32, payload : Bytes)
    io.write_bytes((payload.size.to_u32 << 8) | type.value.to_u32, IO::ByteFormat::BigEndian)
    io.write_byte(flags)
    io.write_bytes(stream_id.to_u32, IO::ByteFormat::BigEndian)
    io.write(payload)
    io.flush
  end
end
