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

      client
    else
      raise Etcd::ConnectionError.new(url)
    end
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

  {% for method in %w(get post put delete) %}
    # Executes a {{method.id.upcase}} request on the etcd client connection.
    #
    # The response status will be automatically checked and a Etcd::ApiError raised if
    # unsuccessful.
    # ```
    def {{method.id}}(path, headers : HTTP::Headers? = nil, body : HTTP::Client::BodyType? = nil)
      prefixed_path = "/#{api_version}#{path}"

      {% if method == "post" %}
        # Client expects non-empty JSON POST body
        body = "{}" if body.nil?
      {% end %}

      if token = @auth_token
        if headers = headers || HTTP::Headers.new
          headers["Authorization"] = token
        end
      end

      begin
        response = connection.{{method.id}}(prefixed_path, headers, body)
      rescue IO::TimeoutError | Socket::ConnectError
        @retries_performed += 1

        if @retries_performed < @endpoints.size
          rotate_endpoints
          return {{method.id}}(path, headers, body)
        else
          raise Etcd::ConnectionError.new(url)
        end
      end

      # if we may be looking at a rotated token, try one more time
      if @auth_token && response.status == HTTP::Status::UNAUTHORIZED
        Log.debug { "Attempting to re-authenticate after HTTP 401" }
        update_auth_token
        return {{method.id}}(path, headers, body)
      else
        raise Etcd::ApiError.from_response(response) unless response.success?
      end

      @retries_performed = 0

      response
    end

    # Executes a {{method.id.upcase}} request and yields a `HTTP::Client::Response`.
    #
    # When working with endpoint that provide stream responses these may be accessed as available
    # by calling `#body_io` on the yielded response object.
    #
    # The response status will be automatically checked and a etcd::ApiError raised if
    # unsuccessful.
    def {{method.id}}(path, headers : HTTP::Headers? = nil, body : HTTP::Client::BodyType = nil)
      path = "/#{api_version}#{path}"

      if token = @auth_token
        if headers = headers || HTTP::Headers.new
          headers["Authorization"] = token
        end
      end

      connection.{{method.id}}(path, headers, body) do |response|
        raise Etcd::ApiError.from_response(response) unless response.success?
        yield response
      end
    end

    # Executes a {{method.id.upcase}} request on the etcd client connection with a JSON body
    # formed from the passed `NamedTuple`... or a `Hash`.
    def {{method.id}}(path, body = nil)
      headers = HTTP::Headers{
        "Content-Type" => "application/json",
      }
      body = to_stringly(body) unless body.nil?
      {{method.id}}(path, headers, body.to_json)
    end

    # :ditto:
    def {{method.id}}(path, headers : HTTP::Headers, body = nil)
      headers["Content-Type"] = "application/json"
      body = to_stringly(body) unless body.nil?
      {{method.id}}(path, headers, body.to_json)
    end

    # Executes a {{method.id.upcase}} request on the etcd client connection with a JSON body
    # formed from the passed `NamedTuple` and yields streamed response entries to the block.
    def {{method.id}}(path, body : NamedTuple | Hash)
      headers = HTTP::Headers{
        "Content-Type" => "application/json",
      }
      body = to_stringly(body) unless body.nil?
      {{method.id}}(path, headers, body.to_json) do |response|
        yield response
      end
    end

    # :ditto:
    def {{method.id}}(path, headers : HTTP::Headers, body : NamedTuple | Hash)
      headers["Content-Type"] = "application/json"
      body = to_stringly(body) unless body.nil?
      {{method.id}}(path, headers, body.to_json) do |response|
        yield response
      end
    end
  {% end %}
end
