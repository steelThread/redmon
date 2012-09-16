require 'redmon/config'
require 'active_support/core_ext'
require 'eventmachine'
require 'haml'
require 'redis'
require 'sinatra/base'
require 'thin'

module Redmon
  extend self

  def run(opts={})
    config.apply opts
    start_em
  rescue Exception => e
    log "!!! Redmon has shit the bed, restarting... #{e.message}"
    sleep(1); run(opts)
  end

  def start_em
    EM.run do
      trap 'TERM', &method(:shutdown)
      trap 'INT',  &method(:shutdown)
      start_app    if config.app
      start_worker if config.worker
    end
  end

  def start_app
    app = Redmon::App.new
    Thin::Server.start(*config.web_interface, app)
    log "listening on http##{config.web_interface.join(':')}"
  rescue Exception => e
    log "Can't start Redmon::App. port in use?  Error #{e}"
  end

  def start_worker
    Worker.new.run!
  end

  def shutdown(code)
    EM.stop
  end

  def log(msg)
    puts "[#{Time.now.strftime('%y-%m-%d %H:%M:%S')}] #{msg}"
  end

  # @deprecated
  def [](option)
    config.send :option
  end

end

require 'redmon/redis'
require 'redmon/helpers'
require 'redmon/app'
require 'redmon/worker'