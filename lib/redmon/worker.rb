class Redmon::Worker
  def initialize(opts)
    @opts = opts
  end

  def run!
    redis = EM::Hiredis.connect(@opts[:redis_url])
    EM::PeriodicTimer.new(@opts[:poll_interval]) do
      redis.info do |info|
        info[:time] = ts = Time.now.to_i * 1000
        redis.zadd(Redmon.info_key, ts, info.to_json)
      end
    end
  end
end