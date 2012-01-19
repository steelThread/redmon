class Redmon::App < Sinatra::Base

  set :haml, :format => :html5
  set :show_exceptions => false
  set :views,         ::File.expand_path('../../../haml', __FILE__)
  set :public_folder, ::File.expand_path('../../../public', __FILE__)

  configure :development do
    require "sinatra/reloader"
    register Sinatra::Reloader
  end

  helpers do
    include Rack::Utils
    include Redmon::RedisUtils

    def redis_url
      @opts[:redis_url]
    end

    def count
      -(params[:count] ? params[:count].to_i : 1)
    end

    def config
      @redis.config :get, '*'
    end

    def prompt
      "#{@opts[:redis_url].gsub('://', ' ')}>"
    end

    def poll_interval
      @opts[:poll_interval] * 1000
    end
  end

  def initialize(opts)
    @opts  = opts
    @redis = Redis.connect(:url => redis_url)
    super(nil)
  end

  get '/' do
    haml :app
  end

  get '/cli' do
    args = params[:command].split
    cmd  = args.shift.downcase
    begin
      raise RuntimeError unless supported? cmd
      @result = @redis.send(cmd.intern, *args)
      @result = empty_result if @result == []
      haml :cli
    rescue ArgumentError
      wrong_number_of_arguments_for cmd
    rescue RuntimeError
      unknown cmd
    rescue Errno::ECONNREFUSED
      connection_refused_for redis_url
    end
  end

  get '/config' do
    content_type :json
    config.to_json
  end

  post '/config' do
    param = params[:param].intern
    value = params[:value]
    @redis.config(:set, param, value)
    value
  end

  get '/info' do
    content_type :json
    @redis.zrange(info_key(ns), count, -1).to_json
  end

  get '/slowlog' do
    content_type :json
    @redis.slowlog(:get).map do |entry|
      {
        :id           => entry.shift,
        :timestamp    => entry.shift,
        :process_time => entry.shift,
        :command      => (cmd = entry.shift).shift,
        :args         => (cmd.shift || []).join(' ')
      }.to_json
    end
  end

  private
    def ns
      @opts[:namespace]
    end

    def redis_url
      @opts[:redis_url]
    end

end