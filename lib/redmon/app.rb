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
    @opts  = opts
    @redis = Redis.connect(:url => opts[:redis_url])
    super(nil)
  end

  get '/' do
    haml :app
  end

  get '/info' do
    content_type :json
    @redis.zrevrange(Redmon.key, count, -1).to_json
  end

  def count
    -params[:count].to_i
  end
end