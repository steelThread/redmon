require 'spec_helper'
require 'redmon/helpers'

include Redmon::Helpers

describe "Helpers" do

  describe "redis" do
    it "should call Redis.connect" do
      Redis.should_receive(:connect).with({:url => Redmon.config.redis_url})
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
      Redmon::Redis.ns.should == Redmon.config.namespace
    end
  end

  describe "#redis_url" do
    it "should return the configured redis url" do
      Redmon::Redis.redis_url.should == Redmon.config.redis_url
    end
  end

  describe "#redis_host" do
    it "should return the configured redis host" do
      config_uri = URI.parse(Redmon.config.redis_url)
      Redmon::Redis.redis_host.should == "#{config_uri.host}:#{config_uri.port}"
    end
  end

  describe "#unquoted" do
    it "should return the configured redis host" do
      Redmon::Redis.unquoted.should == (%w{string OK} << '(empty list or set)')
    end
  end

  describe "#supported?" do
    it "should return true for supported redis commands" do
      Redmon::Redis.supported?(:keys).should be_true
    end

    it "should return false for unsupported redis commands" do
      Redmon::Redis.supported?(:eval).should be_false
    end
  end

  describe "#empty_result" do
    it "should return the empty list message" do
      Redmon::Redis.empty_result.should == '(empty list or set)'
    end
  end

  describe "#unknown" do
    it "should return the unknown command message" do
      Redmon::Redis.unknown("unknown").should == "(error) ERR unknown command 'unknown'"
    end
  end

  describe "#wrong_number_of_arguments_for" do
    it "" do
      Redmon::Redis.wrong_number_of_arguments_for("unknown").should ==
        "(error) ERR wrong number of arguments for 'unknown' command"
    end
  end

  describe "#connection_refused" do
    it "should return the connection refused message" do
      Redmon::Redis.connection_refused.should == "Could not connect to Redis at 127.0.0.1:6379: Connection refused"
    end
  end

  describe "#stats_key" do
    it "should return the namespaced scoped stats key" do
      Redmon::Redis.stats_key.should == "redmon:redis:127.0.0.1:6379:stats"
    end
  end

  describe "#num_samples_to_request" do
    it "should return the number of samples to request based on poll interval and data lifespan" do
      Redmon.config.stub(:data_lifespan).and_return(31)
      Redmon.config.stub(:poll_interval).and_return(10)

      num_samples_to_request.should == (31 * 60) / 10
    end
  end

end
