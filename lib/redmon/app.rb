class Redmon::App < Sinatra::Base

  set :haml, :format => :html5
  set :show_exceptions => false
  set :views,         File.expand_path('../../../haml', __FILE__)
  set :public_folder, File.expand_path('../../../public', __FILE__)

  configure :development do
    require "sinatra/reloader"
    register Sinatra::Reloader
  end

  def count
    -(params[:count] ? params[:count].to_i : 1)
  end

  helpers do
    include Rack::Utils
    include Redmon::Redis

    def prompt
      "#{redis_url.gsub('://', ' ')}>"
    end

    def poll_interval
      Redmon[:poll_interval] * 1000
    end

    def config
      redis.config :get, '*' rescue {}
    end
  end

  get '/' do
    haml :app
  end

  get '/cli' do
    args = params[:command].split
    cmd  = args.shift.downcase
    begin
      raise RuntimeError unless supported? cmd
      @result = redis.send(cmd.intern, *args)
      @result = empty_result if @result == []
      haml :cli
    rescue ArgumentError
      wrong_number_of_arguments_for cmd
    rescue RuntimeError
      unknown cmd
    rescue Errno::ECONNREFUSED
      connection_refused
    end
  end

  post '/config' do
    param = params[:param].intern
    value = params[:value]
    redis.config(:set, param, value)
    value
  end

  get '/stats' do
    content_type :json
    redis.zrange(stats_key, count, -1).to_json
  end

end