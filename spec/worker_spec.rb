require 'spec_helper'

describe "worker" do

  before(:each) do
    @worker = Redmon::Worker.new
  end

  def mock_timer
    double EM::PeriodicTimer
  end

  describe "#run!" do
    it "should poll and record stats" do
      Redmon.config.poll_interval = 1 #reduce the interval to a second for testing
      redis = mock_redis
      allow(@worker).to receive(:stats).and_return(['ts', 'stats'])
      expect(redis).to receive(:zadd).at_least(:twice)
      expect(redis).to receive(:zremrangebyscore).at_least(:twice)

      emThread = Thread.new do
        EM.run do
          @timer = @worker.run!
        end
      end

      puts "sleeping for 3 cycles of Redmon.config.poll_interval: #{Redmon.config.poll_interval} seconds to ensure polling occurred"
      sleep 3 * Redmon.config.poll_interval
      @timer.cancel
      emThread.kill
      @worker.cleanup_old_stats

    end
  end

  describe "#record_stats" do
    it "should record a new stats entry in a redis sorted set" do
      redis = mock_redis
      allow(@worker).to receive(:stats).and_return(['ts', 'stats'])
      expect(redis).to receive(:zadd).with(Redmon::Redis.stats_key, 'ts', 'stats')

      @worker.record_stats
    end
  end

  describe "#cleanup_old_stats" do
    it "should remove old stats entries from a redis sorted set" do
      redis = mock_redis
      expect(redis).to receive(:zremrangebyscore).with(
        Redmon::Redis.stats_key, '-inf', '(' + @worker.oldest_data_to_keep.to_s
      )

      @worker.cleanup_old_stats
    end
  end

  describe "#stats" do
    it "should fetch info, dbsize and slowlog from redis" do
      redis = mock_redis
      expect(redis).to receive(:info).with(no_args()).and_return({})
      expect(redis).to receive(:dbsize).with(no_args()).and_return(0)
      expect(redis).to receive(:slowlog).with(:get).and_return({})

      expect(@worker).to receive(:entries).and_return([{}])
      @worker.stats
    end
  end

  describe "#entries" do
    let (:slowlog) { [[1, 2, 3, ['cmd', 'args']]] }

    it "should parse the sortlog into hashes" do
      entries = @worker.entries slowlog
      expect(entries.length).to eq 1
      entry = entries.shift
      expect(entry).to eq({
        :id           => 1,
        :timestamp    => 2000,
        :process_time => 3,
        :command      => 'cmd args'
      })
    end
  end

  describe "#interval" do
    it "should return the configured poll interval" do
      expect(@worker.interval).to eq Redmon.config.poll_interval
    end
  end

  describe "#data_lifespan" do
    it "should return the data lifspan" do
      expect(@worker.data_lifespan).to eq Redmon.config.data_lifespan
    end
  end

  describe "#oldest_data_to_keep" do
    it "should return the oldest data timestamp that should be kept" do
      allow(Time).to receive(:now).and_return(Time.at(1366044862))
      allow(@worker).to receive(:data_lifespan).and_return(30)

      expect(@worker.oldest_data_to_keep).to eq 1366043062000
    end
  end
end
