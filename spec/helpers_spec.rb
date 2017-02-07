require 'spec_helper'
require 'redmon/helpers'

include Redmon::Helpers

describe "Helpers" do

  describe "redis" do
    it "should call Redis.connect" do
      allow(Redis).to receive(:connect).with({:url => Redmon.config.redis_url})
      Redmon::Redis.redis
    end
  end

  def redis
    @redis ||= ::Redis.connect(:url => redis_url)
  end

  def em_redis
    @em_redis ||= ::EM::Hiredis.connect(redis_url)
  end

  describe "#ns" do
    it "should return the configured namespace" do
      expect(Redmon::Redis.ns).to be Redmon.config.namespace
    end
  end

  describe "#redis_url" do
    it "should return the configured redis url" do
      expect(Redmon::Redis.redis_url).to eq Redmon.config.redis_url
    end
  end

  describe "#redis_host" do
    it "should return the configured redis host" do
      config_uri = URI.parse(Redmon.config.redis_url)
      expect(Redmon::Redis.redis_host).to eq "#{config_uri.host}:#{config_uri.port}"
    end
  end

  describe "#unquoted" do
    it "should return the configured redis host" do
      expect(Redmon::Redis.unquoted).to eq (%w{string OK} << '(empty list or set)')
    end
  end

  describe "#supported?" do
    it "should return true for supported redis commands" do
      expect(Redmon::Redis.supported?(:keys)).to be true
    end

    it "should return false for unsupported redis commands" do
      expect(Redmon::Redis.supported?(:eval)).to be false
    end
  end

  describe "#empty_result" do
    it "should return the empty list message" do
      expect(Redmon::Redis.empty_result).to eq '(empty list or set)'
    end
  end

  describe "#unknown" do
    it "should return the unknown command message" do
      expect(Redmon::Redis.unknown("unknown")).to eq "(error) ERR unknown command 'unknown'"
    end
  end

  describe "#wrong_number_of_arguments_for" do
    it "should return the wrong number of arguments message" do
      expected = "(error) ERR wrong number of arguments for 'unknown' command"
      expect(Redmon::Redis.wrong_number_of_arguments_for("unknown")).to eq expected
    end
  end

  describe "#connection_refused" do
    it "should return the connection refused message" do
      expected = "Could not connect to Redis at 127.0.0.1:6379: Connection refused"
      expect(Redmon::Redis.connection_refused).to eq expected
    end
  end

  describe "#stats_key" do
    it "should return the namespaced scoped stats key" do
      expect(Redmon::Redis.stats_key).to eq "redmon:redis:127.0.0.1:6379:stats"
    end
  end

  describe "#num_samples_to_request" do
    it "should return the number of samples to request based on poll interval and data lifespan" do
      allow(Redmon.config).to receive(:data_lifespan).and_return(31)
      allow(Redmon.config).to receive(:poll_interval).and_return(10)
      expect(num_samples_to_request).to eq ((31 * 60) / 10)
    end
  end
end
