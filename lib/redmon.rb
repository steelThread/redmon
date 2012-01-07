require 'redis'
require "active_support/core_ext"
require 'yajl'
require 'sinatra/base'
require 'haml'
require 'thin'

module Redmon

  DEFAULT_OPTS = {
    :redis_url     => "redis://localhost:6379",
    :web_interface => ["0.0.0.0", 4567]
  }

  def self.run(opts={})
    opts = DEFAULT_OPTS.merge opts
    app  = Redmon::App.new(opts)
    begin
      Thin::Server.start(*opts[:web_interface], app)
      log "listening on http##{opts[:web_interface].join(":")}"
    rescue Exception => e
      log "cant start Redmon::App. port in use?"
    end
  end

  def self.log(msg)
    puts "[#{Time.now.strftime("%y-%m-%d %H:%M:%S")}] #{msg}"
  end

  require "redmon/app"
end
