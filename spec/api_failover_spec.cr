require "./helper"
require "./support/fake_etcd"

private def answer(message : Protobuf::Message)
  {FakeEtcd::Action::Answer, message.as(Protobuf::Message?)}
end

private def drop
  {FakeEtcd::Action::Drop, nil.as(Protobuf::Message?)}
end

# Drops every connection's first request, answers the rest
private def dropping_first_request
  FakeEtcd.new do |request|
    if request.connection == 1
      drop
    else
      case request.method_name
      when "Range" then answer(Etcdserverpb::RangeResponse.new)
      when "Txn"   then answer(Etcdserverpb::TxnResponse.new(succeeded: true))
      else              answer(Etcdserverpb::PutResponse.new)
      end
    end
  end
end

describe "Etcd::Api against a fake member" do
  describe "writes" do
    it "raises Unconfirmed for a put whose connection drops after the request was read" do
      server = dropping_first_request
      client = Etcd::Client.new(server.url)

      error = expect_raises(Etcd::Unconfirmed) { client.kv.put("key", "value") }
      error.cause.should_not be_nil
      server.calls("Put").should eq(1)

      # reconnected, so the next call works
      client.kv.range("key")
      server.connections.should eq(2)
    ensure
      server.try(&.close)
    end

    it "raises Unconfirmed for a txn whose connection drops after the request was read" do
      server = dropping_first_request
      client = Etcd::Client.new(server.url)

      expect_raises(Etcd::Unconfirmed) do
        client.kv.txn(Etcd::Kv::Txn.new.compare_absent("key").put("key", "value"))
      end
      server.calls("Txn").should eq(1)
    ensure
      server.try(&.close)
    end

    it "retries a range whose connection drops after the request was read" do
      server = dropping_first_request
      client = Etcd::Client.new(server.url)

      client.kv.range("key").kvs.should be_empty
      server.calls("Range").should eq(2)
    ensure
      server.try(&.close)
    end

    it "reconnects and sends a put once when the connection was already closed" do
      server = FakeEtcd.new { answer(Etcdserverpb::PutResponse.new) }
      client = Etcd::Client.new(server.url)
      client.api.connection.not_nil!.close

      client.kv.put("key", "value")
      server.calls("Put").should eq(1)
      server.connections.should eq(2)
    ensure
      server.try(&.close)
    end

    it "re-authenticates and sends a put again after UNAUTHENTICATED" do
      tokens = 0
      server = FakeEtcd.new do |request|
        case request.method_name
        when "Authenticate"
          tokens += 1
          answer(Etcdserverpb::AuthenticateResponse.new(token: "token-#{tokens}"))
        else
          if request.headers["authorization"]? == "token-1"
            {FakeEtcd::Action::Refuse, nil.as(Protobuf::Message?)}
          else
            answer(Etcdserverpb::PutResponse.new)
          end
        end
      end
      client = Etcd::Client.new(server.url, username: "user", password: "secret")

      client.kv.put("key", "value")
      puts = server.requests.select { |request| request.method_name == "Put" }
      puts.map(&.headers["authorization"]?).should eq(["token-1", "token-2"])
      server.connections.should eq(1)
    ensure
      server.try(&.close)
    end
  end

  describe "cluster writes" do
    it "raises Unconfirmed for a member_add whose connection drops after the request was read" do
      server = FakeEtcd.new { |request| request.connection == 1 ? drop : answer(Etcdserverpb::MemberAddResponse.new) }
      client = Etcd::Client.new(server.url)

      expect_raises(Etcd::Unconfirmed) { client.cluster.member_add(false, ["http://10.0.0.9:2380"]) }
      server.calls("MemberAdd").should eq(1)
    ensure
      server.try(&.close)
    end
  end

  describe "auth writes" do
    it "raises Unconfirmed for a user_changepw whose connection drops after the request was read" do
      server = FakeEtcd.new { |request| request.connection == 1 ? drop : answer(Etcdserverpb::AuthUserChangePasswordResponse.new) }
      client = Etcd::Client.new(server.url)

      expect_raises(Etcd::Unconfirmed) { client.auth.user_changepw("someone", "new-password") }
      server.calls("UserChangePassword").should eq(1)
    ensure
      server.try(&.close)
    end
  end

  describe "compaction" do
    it "retries after a dropped connection and reports the replay's compacted answer as CompactedError" do
      server = FakeEtcd.new { |request| request.connection == 1 ? drop : {FakeEtcd::Action::Compacted, nil.as(Protobuf::Message?)} }
      client = Etcd::Client.new(server.url)

      error = expect_raises(Etcd::CompactedError) { client.kv.compaction(physical: false, revision: 42_i64) }
      error.revision.should eq(42)
      server.calls("Compact").should eq(2)
    ensure
      server.try(&.close)
    end
  end

  describe "Watcher#stop" do
    it "ends start on an idle stream without waiting for a frame" do
      server = FakeEtcd.new { {FakeEtcd::Action::Hang, nil.as(Protobuf::Message?)} }
      watcher = Etcd::Client.new(server.url).watch.watch("key") { }
      finished = Channel(Nil).new(1)
      spawn do
        watcher.start
        finished.send(nil)
      end
      wait_for { watcher.watching? }
      sleep 50.milliseconds

      watcher.stop
      select
      when finished.receive
      when timeout(2.seconds)
        fail "start did not return after stop"
      end
    ensure
      server.try(&.close)
    end
  end

  describe "#reconnect" do
    it "moves to the next member when one accepts connections and never answers" do
      hung = FakeEtcd.new { {FakeEtcd::Action::Hang, nil.as(Protobuf::Message?)} }
      healthy = FakeEtcd.new { answer(Etcdserverpb::RangeResponse.new) }
      client = Etcd::Client.new([hung.url, healthy.url])
      client.api.request_timeout = 200.milliseconds
      client.api.connection.not_nil!.request_timeout = 200.milliseconds

      client.kv.range("key")
      hung.calls("Range").should eq(1)
      healthy.calls("Range").should eq(1)
      client.api.url.should eq(healthy.url)
    ensure
      hung.try(&.close)
      healthy.try(&.close)
    end
  end
end

# Accepts connections and answers each with an HTTP/1.1 response, as a non-etcd listener would
private class NotHttp2Server
  @server = TCPServer.new("127.0.0.1", 0)
  @clients = [] of TCPSocket

  def initialize
    spawn do
      while socket = @server.accept?
        @clients << socket
        socket.write("HTTP/1.1 400 Bad Request\r\nContent-Length: 0\r\n\r\n".to_slice) rescue nil
      end
    end
  end

  def url : URI
    URI.parse("http://127.0.0.1:#{@server.local_address.port}")
  end

  def close
    @server.close rescue nil
    @clients.each { |client| client.close rescue nil }
  end
end

describe "Etcd::Api connecting" do
  it "moves to the next member when the first one doesn't speak HTTP/2" do
    bad = NotHttp2Server.new
    good = FakeEtcd.new { |_request| answer(Etcdserverpb::RangeResponse.new) }
    client = Etcd::Client.new([bad.url, good.url])

    client.kv.range("key").kvs.should be_empty
    good.connections.should eq(1)
  ensure
    bad.try(&.close)
    good.try(&.close)
  end

  it "raises ConnectionError carrying the TLS error when no member completes a handshake" do
    servers = Array.new(2) { NotHttp2Server.new }
    # the client connects as it is constructed
    error = expect_raises(Etcd::ConnectionError) do
      Etcd::Client.new(servers.map(&.url), tls_context: OpenSSL::SSL::Context::Client.new)
    end
    error.cause.should be_a(OpenSSL::SSL::Error)
  ensure
    servers.try(&.each(&.close))
  end
end
