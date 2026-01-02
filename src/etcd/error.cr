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

  class ConnectionError < Error
    def initialize
      super("Could not connect to any etcd endpoints")
    end
  end
end
