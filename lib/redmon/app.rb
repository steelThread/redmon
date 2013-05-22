require 'sinatra/base'
require 'redmon/helpers'
require 'haml'

module Redmon
  class App < Sinatra::Base

    helpers Redmon::Helpers

    set :root, File.dirname(__FILE__)
    set :views, Proc.new { File.join(root, "./views") }

    use Rack::Static, {
      :urls => [/\.css$/, /\.js$/],
      :root => "#{root}/public",
      :cache_control => 'public, max-age=3600'
    }

    if Redmon.config.secure
      use Rack::Auth::Basic do |username, password|
        [username, password] == Redmon.config.secure.split(':')
      end
    end

    get '/' do
      haml :app
    end

    get '/cli' do
      args = params[:command].split(/ *"(.*?)" *| *'(.*?)' *| /)
      args.reject!(&:blank?)
      @cmd = args.shift.downcase.intern
      begin
        raise RuntimeError unless supported? @cmd
        @result = redis.send @cmd, *args
        @result = empty_result if @result == []
        haml :cli
      rescue ArgumentError
        wrong_number_of_arguments_for @cmd
      rescue RuntimeError
        unknown @cmd
      rescue Errno::ECONNREFUSED
        connection_refused
      end
    end

    post '/config' do
      param = params[:param].intern
      value = params[:value]
      redis.config(:set, param, value) and value
    end

    get '/stats' do
      content_type :json
      redis.zrange(stats_key, count, -1).to_json
    end

  end
end
