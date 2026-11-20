require "http"

module Etcd
  class Error < ::Exception
    getter message
  end

  class ApiError < Error
    def initialize(@status_code : Int32, message = "", cause = nil)
      super(message, cause: cause)
    end
  end

  class WatchError < Error
  end

  # A gRPC stream carried bytes that cannot be a length-prefixed message
  class FramingError < Error
  end

  # A read at a revision etcd has compacted away; read again at the latest revision.
  class CompactedError < GRPC::BadStatus
    getter revision : Int64

    def initialize(@revision : Int64, message : String)
      super(GRPC::StatusCode::OUT_OF_RANGE, message)
    end

    def self.from?(error : GRPC::BadStatus, revision : Int64) : self?
      return nil unless error.code.out_of_range?
      return nil unless error.message.includes?("required revision has been compacted")
      new(revision, error.@message || "")
    end
  end

  # A write's connection failed after the request may have reached etcd: it may or may not have
  # been applied. Read back to find out; the request was not replayed.
  class Unconfirmed < Error
    def initialize(cause : Exception)
      super("etcd write unconfirmed: #{cause.message}", cause: cause)
    end
  end

  class ConnectionError < Error
    def initialize(cause : Exception? = nil)
      super("Could not connect to any etcd endpoints", cause: cause)
    end
  end
end
