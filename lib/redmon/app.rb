class Redmon::App < Sinatra::Base

  set :haml, :format => :html5
  set :views,         ::File.expand_path('../../../haml', __FILE__)
  set :public_folder, ::File.expand_path('../../../public', __FILE__)

  helpers do
    include Rack::Utils

    def redis_url
      @opts[:redis_url]
    end
  end

  def initialize(opts)
    @redis = Redis.connect(:url => opts[:redis_url])
    @opts = opts
    super(nil)
  end

  get '/' do
    haml :app
  end

  get '/info' do
    @redis.info.to_json
  end
end