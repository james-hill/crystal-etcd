require "log"
require "http2"
require "grpc"

require "./etcd/api"
require "./etcd/client"
require "./protobufs/*"

module Etcd
  Log = ::Log.for(self)
  extend self

  VERSION = `shards version`

  def from_env
    client(
      host: ENV["ETCD_HOST"]? || "localhost",
      port: ENV["ETCD_PORT"]?.try(&.to_i) || 2379,
      username: ENV["ETCD_USERNAME"]?,
      password: ENV["ETCD_PASSWORD"]?,
    )
  end

  def client(url : URI, username : String? = nil, password : String? = nil)
    Etcd::Client.new(url: url, username: username, password: password)
  end

  def client(host : String, port : Int32? = nil, username : String? = nil, password : String? = nil)
    Etcd::Client.new(host: host, port: port, username: username, password: password)
  end

  def api(url : URI)
    Etcd::Api.new(url: url)
  end

  def api(host : String, port : Int32? = nil)
    Etcd::Api.new(host: host, port: port)
  end
end
