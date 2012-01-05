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

  def self.default_options(opts)
    opts[:web_interface] ||= ["0.0.0.0", "4242"]
    opts
  end

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

    end
  end

  def self.log(msg)
    puts "[#{Time.now.strftime("%y-%m-%d %H:%M:%S")}] #{msg}"
  end

  def self.run(opts={})
    start_em(opts)
  rescue Exception => e
    log "!!! eventmachine died, restarting... #{e.message}"
    sleep(1); run(opts)
  end

  def self.shutdown
    log "shutting down, byebye"
    EM.stop
  end

  def self.standalone
    require "redmon/standalone"
  end

  require "redmon/app"
end
