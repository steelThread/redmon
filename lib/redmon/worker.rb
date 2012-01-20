#
# TODO: need to add the slow log as part of the stats that are captured
#       for each poll cycle.
#
class Redmon::Worker
  include Redmon::RedisUtils

  def initialize(opts)
    @ns, @url, @interval = opts[:namespace], opts[:redis_url], opts[:poll_interval]
  end

  def run!
    redis = EM::Hiredis.connect(@url)
    EM::PeriodicTimer.new(@interval) do
      # TODO: make this a multi for a single io - research error
      # getting this exception with em::hiredis when attempting this
      # ndefined method `chomp' for nil:NilClass @client.rb:137
      redis.info do |info|
        info[:time] = ts = Time.now.to_i * 1000
        info[:last_save_time] = info[:last_save_time].to_i * 1000
        redis.dbsize do |dbsize|
          info[:dbsize] = dbsize
        end
      end
    end
  end

end