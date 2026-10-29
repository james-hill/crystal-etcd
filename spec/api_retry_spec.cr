require "./helper"

# Connecting would dial the endpoint: hand out a config with no connection and count reconnects
private class RetryProbeApi < Etcd::Api
  getter reconnects = 0

  def config
    @config ||= GRPC::Config.new
  end

  def reconnect
    @reconnects += 1
  end
end

# Building the real client's Auth dials the endpoint too; the api only needs it for re-authentication
private class OfflineClient < Etcd::Client
  private def after_initialize
  end
end

private def probe_api(max_retries = nil)
  client = OfflineClient.new(URI.parse(NONEXISTENT_ENDPOINT))
  RetryProbeApi.new(client, [URI.parse(NONEXISTENT_ENDPOINT)], max_retries: max_retries)
end

describe Etcd::Api do
  describe "#with_retry" do
    it "retries a timed-out call once, then raises" do
      api = probe_api(max_retries: 5)
      attempts = 0

      expect_raises(IO::TimeoutError) do
        api.with_retry do
          attempts += 1
          raise IO::TimeoutError.new("no answer within 30s")
        end
      end

      attempts.should eq(2)
      api.reconnects.should eq(1)
    end

    it "returns the result when the retry after a timeout succeeds" do
      api = probe_api(max_retries: 5)
      attempts = 0

      result = api.with_retry do
        attempts += 1
        raise IO::TimeoutError.new("no answer within 30s") if attempts == 1
        :ok
      end

      result.should eq(:ok)
      api.reconnects.should eq(1)
    end

    it "still retries other IO errors up to max_retries" do
      api = probe_api(max_retries: 3)
      attempts = 0

      expect_raises(IO::Error) do
        api.with_retry do
          attempts += 1
          raise IO::Error.new("connection reset")
        end
      end

      attempts.should eq(4)
      api.reconnects.should eq(3)
    end
  end
end
