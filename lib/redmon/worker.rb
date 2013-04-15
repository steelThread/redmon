module Redmon
  class Worker
    include Redmon::Redis

    def run!
      EM::PeriodicTimer.new(interval) {
        record_stats
        cleanup_old_stats
      }
    end

    def record_stats
      redis.zadd stats_key, *stats
    end

    def cleanup_old_stats
      # When indexing from the end of a sorted set, we start at -1, so we need to add 1 here or we'll be keeping one
      # fewer samples than expected
      redis.zremrangebyrank stats_key, 0, -(num_samples_to_keep + 1)
    end

    def stats
      stats = redis.info.merge! \
        :dbsize  => redis.dbsize,
        :time    => ts = Time.now.to_i * 1000,
        :slowlog => entries(redis.slowlog :get)
      [ts, stats.to_json]
    end

    def entries(slowlog)
      sort(slowlog).map do |entry|
        {
          :id           => entry.shift,
          :timestamp    => entry.shift * 1000,
          :process_time => entry.shift,
          :command      => entry.shift.join(' ')
        }
      end
    end

    def sort(slowlog)
      slowlog.sort_by{|a| a[2]}.reverse!
    end

    def interval
      Redmon.config.poll_interval
    end

    def num_samples_to_keep
      Redmon.config.num_samples_to_keep
    end

  end
end
