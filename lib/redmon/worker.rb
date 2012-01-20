#
# TODO: need to add the slow log as part of the stats that are captured
#       for each poll cycle.
#
class Redmon::Worker
  include Redmon::Redis

  def run!
    redis = EM::Hiredis.connect(@url)
    EM::PeriodicTimer.new(Redmon[:poll_interval]) do
      # multi here - hiredis doesn't appear to support parsing of results
      # for slowlog or info in a multi
      redis.info do |info|
        info[:time] = ts = Time.now.to_i * 1000
        info[:last_save_time] = info[:last_save_time].to_i * 1000
        redis.dbsize do |dbsize|
          info[:dbsize] = dbsize
          redis.zadd(info_key, ts, info.to_json)
        end
      end
    end
  end

end