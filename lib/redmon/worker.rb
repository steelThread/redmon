#
# TODO: need to add the slow log as part of the stats that are captured
#       for each poll cycle.
#
class Redmon::Worker
  include Redmon::Redis

  def run!
    EM::PeriodicTimer.new(Redmon[:poll_interval]) do
      # multi here - hiredis doesn't appear to support parsing of results
      # for slowlog or info in a multi
      # THIS IS GROSS!!!!
      em_redis.info do |info|
        info[:slowlog] = slowlog
        info[:time] = ts = Time.now.to_i * 1000
        info[:last_save_time] = info[:last_save_time].to_i * 1000
        em_redis.dbsize do |dbsize|
          info[:dbsize] = dbsize
          em_redis.zadd(stats_key, ts, info.to_json)
        end
      end
    end
  end

  def slowlog
    slowlog = redis.slowlog(:get).sort_by{|a| a[2]}.reverse!
    slowlog.map do |entry|
      {
        :id           => entry.shift,
        :timestamp    => entry.shift * 1000,
        :process_time => entry.shift,
        :command      => entry.shift.join(' ')
      }
    end
  end

end