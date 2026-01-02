require "http"

require "./error"

class Etcd::Api
  DEFAULT_HOST    = "localhost"
  DEFAULT_PORT    = 2379
  DEFAULT_DNS_TIMEOUT = 2.seconds
  DEFAULT_CONNECT_TIMEOUT = 1.second
  
  getter client : Etcd::Client  # don't confuse this with the GRPC::Client!
  getter endpoints = [] of URI
  getter tls_context : HTTP::Client::TLSContext = false
  getter dns_timeout : Time::Span = DEFAULT_DNS_TIMEOUT
  getter connect_timeout : Time::Span = DEFAULT_CONNECT_TIMEOUT
  getter max_retires

  # keeps track of the number of times we've tried to connect since the last successful request
  # (will be used to keep trying if we have multiple endpoints)
  getter retries_performed = 0
  
  # If nil, will retry all endpoints
  setter max_retries : Int32? = nil 

  getter! config : GRPC::Config?

  # If we're using RBAC with username/password (NOT TLS cert common name auth) then we need a token
  @auth_token : String? = nil

  def initialize(
    @client : Etcd::Client,
    @endpoints : Array(URI),
    @username : String? = nil,
    @password : String? = nil,
    @tls_context : HTTP::Client::TLSContext = false,
    @dns_timeout : Time::Span = DEFAULT_DNS_TIMEOUT,
    @connect_timeout : Time::Span = DEFAULT_CONNECT_TIMEOUT,
    @auth_token : String? = nil,
    @max_retries : Int32? = nil,
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

  
  # current url (will change when rotate_endpoints is called)
  def url
    @endpoints.first
  end

  def rotate_endpoints
    @endpoints.rotate!
  end

  # this is what we pass to all the services
  def config
    @config ||= GRPC::Config.new(http2: create_http2_client)
  end

  def reconnect
    config.http2.try(&.close)
    config.http2 = create_http2_client
  end

  # will do nothing unless the client has a username/password
  def reauthenticate
    # ask the client (which knows about Auth, etc) to reassign us a token
    @client.maybe_authenticate
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
      rescue error : IO::Error
        Log.warn(exception: error) {"Error connecting to #{url}... will rotate and try again, if possible"}
        rotate_endpoints
      end        
    end

    raise Etcd::ConnectionError.new
  end

  def connection
    config.http2
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

  # def with_nonreturning_retry(&)
  #   # retry each endpoint
  #   @endpoints.size.times do
  #     begin
  #       yield
  #       break
  #     rescue error : IO::Error
  #       reconnect
  #     end
  #   end
  # end
  
  def max_retries
    case @max_retries 
    when Int32
      @max_retries.as(Int32)
    when Nil
      @endpoints.size
    else
      0
    end
  end
  

  # wraps a block and attempts to deal with down nodes and expired auth tokens
  def with_retry(&)
    loop do
      begin
        if config.http2.try(&.closed?)  
          Log.warn {"Underlying http2 connection is closed"}
          raise Etcd::ConnectionError.new 
        else
          result = yield

          # success so reset the retry counter
          @retries_performed = 0

          return result
        end
      rescue error : IO::Error | Etcd::ConnectionError
        if @retries_performed < max_retries
          reconnect
          @retries_performed += 1
        else
          raise error
        end     
      rescue error : GRPC::BadStatus
        # if the error is UNAUTHENTICATED then we may just need to rotate the auth token
        if error.code == GRPC::StatusCode::UNAUTHENTICATED
          Log.info {"Attempting to rotate auth token at #{url} because of GRPC error: UNAUTHENTICATED"}
          if @retries_performed < max_retries
            reauthenticate
            @retries_performed += 1
          else
            raise error
          end     
        else
          # Don't trap any other sort of bad status
          raise error
        end
      end
    end

    raise "Failed to reconnect"
  end
end
