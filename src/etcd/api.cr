require "http"

require "./error"

class Etcd::Api
  DEFAULT_HOST    = "localhost"
  DEFAULT_PORT    = 2379
  DEFAULT_DNS_TIMEOUT = 2.seconds
  DEFAULT_CONNECT_TIMEOUT = 1.second

  getter endpoints = [] of URI
  getter tls_context : HTTP::Client::TLSContext = false
  getter dns_timeout : Time::Span = DEFAULT_DNS_TIMEOUT
  getter connect_timeout : Time::Span = DEFAULT_CONNECT_TIMEOUT

  # keeps track of the number of times we've tried to connect since the last successful request
  # (will be used to keep trying if we have multiple endpoints)
  getter retries_performed = 0

  # will be rebuilt on failure to point to the next endpoint
  getter! config : GRPC::Config?

  # If we're using RBAC with username/password (NOT TLS cert common name auth) then we need a token
  @auth_token : String? = nil

  def initialize(
    @endpoints : Array(URI),
    @username : String? = nil,
    @password : String? = nil,
    @tls_context : HTTP::Client::TLSContext = false,
    @dns_timeout : Time::Span = DEFAULT_DNS_TIMEOUT,
    @connect_timeout : Time::Span = DEFAULT_CONNECT_TIMEOUT,
    @auth_token : String? = nil,
  )

  end


  # Converts literals to string type
  protected def to_stringly(value)
    case value
    when Array, Tuple
      value.map { |v| to_stringly(v) }
    when Hash
      value.transform_values { |v| to_stringly(v) }
    when NamedTuple
      to_stringly(value.to_h)
    when String
    value.as(String)
    when Bool
      value
    else
      value.to_s
    end
  end

  # :no_doc:
  # used to move to the next available endpoint in case of failure
  # exposed for the unit tests
  def rotate_endpoints
    Log.debug { "Rotating endpoints" }
    @endpoints.rotate!
    @config = create_config
  end

  # current url (may change on failure)
  def url
    @endpoints.first
  end

  # this is what we pass to all the services
  def config
    @config ||= create_config
  end

  def reconnect
    rotate_endpoints
    config.http2 = create_http2_client
  end

  protected def create_config
    GRPC::Config.new(http2: create_http2_client)
  end

  protected def create_http2_client
    @endpoints.size.times do
      begin
        if (host = url.host) && (port = url.port)
          client = GRPC::Client.new(
            host: host,
            port: port,
            ssl_context: @tls_context || false,
            dns_timeout: @dns_timeout,
            connect_timeout: @connect_timeout,
          )
          if token = @auth_token
            client.default_headers["Authorization"] = token
          end

          return client
        end
      rescue Socket::ConnectError
        # try the next one
        rotate_endpoints
      end
    end

    raise Etcd::ConnectionError.new(url)
  end

  def auth_token=(token : String?)
    if http2 = config.http2
      if tok = token
        http2.default_headers["Authorization"] = tok
      else
        http2.default_headers.delete("Authorization")
      end
    end
  end
end
