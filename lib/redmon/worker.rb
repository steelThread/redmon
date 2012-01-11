class Redmon::Worker
  def initialize(opts)
    @ns        = opts[:namespace]
    @url       = opts[:redis_url]
    @interval  = opts[:poll_interval]
  end

  def run!
    redis = EM::Hiredis.connect(@url)
    EM::PeriodicTimer.new(@interval) do
      redis.info do |info|
        info[:time] = ts = Time.now.to_i * 1000
        redis.zadd(key, ts, info.to_json)
      end
    end
  end

  def key
    @key ||= "#{@ns}:redis.info"
  end
end