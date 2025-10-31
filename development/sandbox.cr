require "../src/etcd"

Log.setup_from_env

#io = TCPSocket.new("127.0.0.1", 2379)
#io = TCPSocket.new("127.0.0.1", 12345)

tls_context = OpenSSL::SSL::Context::Client.from_hash(
    {
      "verify_mode" => "none",
      "key" => "/Users/james/Projects/crystal-etcd/development/cfssl/client1-key.pem",
      "cert" => "/Users/james/Projects/crystal-etcd/development/cfssl/client1.pem",
      "ca" => "/Users/james/Projects/crystal-etcd/development/cfssl/ca.pem",
    }
  )

client = Etcd::Client.new("127.0.0.1", 2379, username: "root", password: "3E02f565b1bc0357", tls_context: tls_context)
#client = Etcd::Client.new("127.0.0.1", 2379)
pp client.cluster.member_list

# abort

# EtcdService = Etcdserverpb::Maintenance::Stub.new

# # GRPC::Config.defaults do |config|
# #   tls_context = OpenSSL::SSL::Context::Client.from_hash(
# #     {
# #       "verify_mode" => "none",
# #       "key" => "/Users/james/Projects/crystal-etcd/development/cfssl/client1-key.pem",
# #       "cert" => "/Users/james/Projects/crystal-etcd/development/cfssl/client1.pem",
# #       "ca" => "/Users/james/Projects/crystal-etcd/development/cfssl/ca.pem",
# #     }
# #   )
# #   tls_context.security_level = 1

# #   config.http2 = GRPC::Client.new("127.0.0.1", 2379, tls_context)

# # end

# # These will be used unless overridden per service
# # GRPC.defaults do |config|
# #   tls_context = OpenSSL::SSL::Context::Client.from_hash(
# #     {
# #       "verify_mode" => "none",
# #       "key" => "/Users/james/Projects/crystal-etcd/development/cfssl/client1-key.pem",
# #       "cert" => "/Users/james/Projects/crystal-etcd/development/cfssl/client1.pem",
# #       "ca" => "/Users/james/Projects/crystal-etcd/development/cfssl/ca.pem",
# #     }
# #   )
# #   tls_context.security_level = 1

# #   config.http2 = GRPC::Client.new("127.0.0.1", 2379, tls_context)
# # end

# pp EtcdService.status(::Etcdserverpb::StatusRequest.new)




# (1..5).each do |i|
#   sleep 1
#   Log.warn {"#{i} sending settings"}
#   client.connection.send_settings
# end

# io = OpenSSL::SSL::Socket::Client.new(io, tls_context, hostname: "127.0.0.1")
# scheme = "https"

# connection = HTTP2::Connection.new(io, HTTP2::Connection::Type::CLIENT)
# connection.write_client_preface
# connection.write_settings


# frame = connection.receive
# unless frame.try(&.type) == HTTP2::Frame::Type::SETTINGS
#   raise "Expected SETTINGS frame"
# end


# headers = HTTP::Headers{
#   ":method"    => "POST",
#   ":path"      => "/etcdserverpb.Maintenance/Status",
#   "te"         => "trailers",
#   "user-agent" => "crystal",
#   "content-type" => "application/grpc",
#   "service-name" => "etcdserverpb.Maintenance",
# }

# sr = ::Etcdserverpb::StatusRequest.new
# io = IO::Memory.new

# request_payload = sr.to_protobuf.to_slice

# io.write_bytes(0_u8) # Not compressed
# io.write_bytes(request_payload.size, IO::ByteFormat::BigEndian)
# io.write request_payload

# client.request(headers, io.to_slice) do |response_headers, body|
#   Log.warn { "\n\n*** RESPONSE HEADERS #{response_headers.inspect}/n/n" }

#   raw = Bytes.new(body.size - 5)
#   body.read(raw)
#   raw_io = IO::Memory.new(raw)

#   compressed = raw_io.read_byte != 0

#   #deal with length prefix
#   raw_io.read_byte
#   raw_io.read_byte
#   raw_io.read_byte
#   raw_io.read_byte

#   response = ::Etcdserverpb::StatusResponse.from_protobuf(raw_io)

#   Log.warn {"\n\n*** RESPONSE BODY #{response.inspect} \n\n"}

#   # stuff = Bytes.new(body.size)
#   # print stuff.inspect


#   # while line = body.gets_to_end
#   #   puts "RES #{line}"
#   # end
# end

# client.close

# puts "DONE"
# abort


#127.0.0.1:2379 etcdserverpb.Maintenance/StatusRequest