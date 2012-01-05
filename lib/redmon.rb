require 'rubygems'
require "eventmachine"
require 'em-hiredis'
require 'redis'
require "active_support/core_ext"
require 'yajl'
require 'sinatra/base'
require 'haml'
require 'thin'

module Redmon

  #
  # setup the options
  #
  def self.default_options(opts)
    opts[:redis_url]     ||= "redis://localhost:6379"
    opts[:web_interface] ||= ["0.0.0.0", 4242]
    opts[:print_info]    ||= 20
    opts
  end

  #
  # startup event machine
  #
  def self.start_em(opts)
    EM.run do
      trap("TERM", &method(:shutdown))
      trap("INT",  &method(:shutdown))

      opts = default_options(opts)
      if opts[:web_interface]
        begin
          app = Redmon::App.new
          Thin::Server.start(*opts[:web_interface], app)
          log "listening on http##{opts[:web_interface].join(":")}"
        rescue Exception => e
          log "cant start Redmon::App. port in use?"
        end
      end

      redis = connect_redis(opts[:redis_url])
      EM::PeriodicTimer.new(opts[:print_info]) do
        print_info(redis)
      end
    end
  end

  #
  # log to stdio
  #
  def self.log(msg)
    puts "[#{Time.now.strftime("%y-%m-%d %H:%M:%S")}] #{msg}"
  end

  #
  # run remon
  #
  def self.run(opts={})
    start_em(opts)
  rescue Exception => e
    log "!!! eventmachine died, restarting... #{e.message}"
    sleep(1); run(opts)
  end

  #
  # open a redis connection
  #
  def self.connect_redis(redis_url)
    EM::Hiredis.connect(redis_url)
  end

  #
  # time to shutdown
  #
  def self.shutdown
    log "shutting down, byebye"
    EM.stop
  end

  def self.print_info(redis)
    redis.info do |info|
      log "Memory used: #{info[:used_memory_human]}"
    end
  end

  require "redmon/app"
end
