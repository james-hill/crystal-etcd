require "./kv"
require "./auth"
require "./lease"
require "./maintenance"
require "./cluster"
require "./watch"

class Etcd::Client
  getter! api : Etcd::Api
  getter endpoints = [] of URI
  getter username : String? = nil
  getter password : String? = nil
  getter tls_context : HTTP::Client::TLSContext

  delegate close, to: api.connection

  def initialize(
    url : URI,
    @username : String? = nil,
    @password : String? = nil,
    @tls_context : HTTP::Client::TLSContext = nil,
  )
    @endpoints << url
    after_initialize
  end

  def initialize(
    @endpoints : Array(URI),
    @username : String? = nil,
    @password : String? = nil,
    @tls_context : HTTP::Client::TLSContext = nil,
  )
    after_initialize
  end

  def initialize(
    host : String = "localhost",
    port : Int32? = nil,
    @username : String? = nil,
    @password : String? = nil,
    @tls_context : HTTP::Client::TLSContext = nil,
  )
    @endpoints << URI.new(host: host, port: port)
    after_initialize
  end

  # special setter since we need to make a gRPC request and update the token
  # Note: called without parameters will clear the current username/password
  def authenticate(username : String? = nil, password : String? = nil)
    @username = username
    @password = password
    api.auth_token = if (un = username) && (pw = password)
      auth.authenticate(un, pw)
    else
      nil
    end
  end

  def maybe_authenticate
    if (username = @username) && (password = @password)
      authenticate(username, password)
    else
      Log.debug {"Skipping username/password authentication because no password was supplied"} if @username
    end
  end

  {% for component in %w(kv lease maintenance watch auth cluster) %}
    # Provide an object for managing {{component.id}}. See `Docker::{{component.id.capitalize}}`.
    def {{component.id}} : {{component.id.capitalize}}
      @{{component.id}} ||= {{component.id.capitalize}}.new(api.config)
    end
  {% end %}

  private def after_initialize
    @api = Etcd::Api.new(
      endpoints: @endpoints,
      tls_context: @tls_context
    )
    @auth = Etcd::Auth.new(api.config)
    maybe_authenticate
  end
end
