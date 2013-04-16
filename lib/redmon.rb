require 'eventmachine'
require 'active_support/core_ext'

module Redmon
  extend self

  def run(opts={})
    config.apply opts
    start_em
  rescue Exception => e
    unless e.is_a?(SystemExit)
      log "!!! Redmon has shit the bed, restarting... #{e.message}"
      e.backtrace.each { |line| log line }
      sleep(1)
      run(opts)
    end
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
    require 'thin'
    Thin::Server.start(*config.web_interface) do
      run Redmon::App.new
    end
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

  require 'redmon/config'
  require 'redmon/redis'

  autoload :App,    'redmon/app'
  autoload :Worker, 'redmon/worker'

end
