class Redmon::App < Sinatra::Base

  set :haml, :format => :html5
  set :views,         ::File.expand_path('../../../haml', __FILE__)
  set :public_folder, ::File.expand_path('../../../public', __FILE__)

  helpers do
    include Rack::Utils
    alias_method :h, :escape_html
  end

  def initialize(opts)
    @redis = Redis.connect(:url => opts[:redis_url])
    @opts = opts
    super(nil)
  end

  get '/' do
    haml :app
  end

  get '/random' do
    {value: rand(100)}.to_json
  end

  get '/info' do
    @redis.info.to_json
  end
end