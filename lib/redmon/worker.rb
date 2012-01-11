class Redmon::Worker
  include Redmon::RedisUtils

  def initialize(opts)
    @ns, @url, @interval = opts[:namespace], opts[:redis_url], opts[:poll_interval]
  end

  def run!
    redis = EM::Hiredis.connect(@url)
    EM::PeriodicTimer.new(@interval) do
      redis.info do |info|
        info[:time] = ts = Time.now.to_i * 1000
        redis.zadd(info_key(@ns), ts, info.to_json)
      end
    end
  end

end