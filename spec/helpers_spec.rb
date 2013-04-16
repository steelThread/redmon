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
      Redmon.config.namespace.should == Redmon::Redis.ns
    end
  end

  describe "#redis_url" do
    it "should return the configured redis url" do
      Redmon.config.redis_url.should == Redmon::Redis.redis_url
    end
  end

  describe "#redis_host" do
    it "should return the configured redis host" do
      Redmon.config.redis_url.gsub('redis://', '').should == Redmon::Redis.redis_host
    end
  end

  describe "#unquoted" do
    it "should return the configured redis host" do
      (%w{string OK} << '(empty list or set)').should == Redmon::Redis.unquoted
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
      '(empty list or set)'.should == Redmon::Redis.empty_result
    end
  end

  describe "#unknown" do
    it "should return the unknown command message" do
      "(error) ERR unknown command 'unknown'".should == Redmon::Redis.unknown('unknown')
    end
  end

  describe "#wrong_number_of_arguments_for" do
    it "" do
      "(error) ERR wrong number of arguments for 'unknown' command".should ==
        Redmon::Redis.wrong_number_of_arguments_for('unknown')
    end
  end

  describe "#connection_refused" do
    it "should return the connection refused message" do
      "Could not connect to Redis at 127.0.0.1:6379: Connection refused".should ==
        Redmon::Redis.connection_refused
    end
  end

  describe "#stats_key" do
    it "should return the namespaced scoped stats key" do
      "redmon:redis:127.0.0.1:6379:stats".should == Redmon::Redis.stats_key
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
