require 'active_support/core_ext'
require 'eventmachine'
require 'em-hiredis'
require 'haml'
require 'redis'
require 'sinatra/base'
require 'thin'

module Redmon
  extend self

  DEFAULT_OPTS = {
    :redis_url     => 'redis://127.0.0.1:6379',
    :namespace     => 'redmon',
    :web_interface => ['0.0.0.0', 4567],
    :worker        => true,
    :poll_interval => 10
  }

  def start_em(opts)
    EM.run do
      trap('TERM', &method(:shutdown))
      trap('INT',  &method(:shutdown))

      @opts = DEFAULT_OPTS.merge opts
      start_app    if @opts[:web_interface]
      start_worker if @opts[:worker]
    end
  end

  def run(opts={})
    start_em(opts)
  rescue Exception => e
    log "!!! eventmachine died, restarting... #{e.message}"
    puts e.backtrace
    sleep(1); run(opts)
  end

  def start_app
    app = Redmon::App.new(@opts)
    Thin::Server.start(*@opts[:web_interface], app)
    log "listening on http##{@opts[:web_interface].join(':')}"
  rescue Exception => e
    log "got an error #{e}"
    log "can't start Redmon::App. port in use?"
  end

  def start_worker
    Worker.new(@opts).run!
  end

  def shutdown
    EM.stop
  end

  def log(msg)
    puts "[#{Time.now.strftime('%y-%m-%d %H:%M:%S')}] #{msg}"
  end

end

require 'redmon/redis_utils'
require 'redmon/app'
require 'redmon/worker'