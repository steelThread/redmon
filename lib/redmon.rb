require "active_support/core_ext"
require "eventmachine"
require 'em-hiredis'
require 'haml'
require 'redis'
require 'sinatra/base'
require 'thin'
require 'yajl'

module Redmon

  DEFAULT_OPTS = {
    :redis_url     => "redis://localhost:6379",
    :namespace     => "redmon",
    :web_interface => ["0.0.0.0", 4567],
    :worker        => true,
    :poll_interval => 10
  }

  def self.start_em(opts)
    EM.run do
      trap("TERM", &method(:shutdown))
      trap("INT",  &method(:shutdown))

      @opts = DEFAULT_OPTS.merge opts

      if @opts[:worker]
        Worker.new(@opts).run!
      end

      if @opts[:web_interface]
        begin
          app = Redmon::App.new(@opts)
          Thin::Server.start(*@opts[:web_interface], app)
          log "listening on http##{@opts[:web_interface].join(":")}"
        rescue Exception => e
          log "got an error #{e}"
          log "can't start Redmon::App. port in use?"
        end
      end
    end
  end

  def self.run(opts={})
    start_em(opts)
  rescue Exception => e
    puts e
    log "!!! eventmachine died, restarting... #{e.message}"
    sleep(1); run(opts)
  end

  def self.shutdown
    log "shutting down, byebye"
    EM.stop
  end

  def self.key
    "#{@opts[:namespace]}:redis.info"
  end

  def self.log(msg)
    puts "[#{Time.now.strftime("%y-%m-%d %H:%M:%S")}] #{msg}"
  end

  require "redmon/app"
  require "redmon/worker"
end
