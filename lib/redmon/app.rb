class Redmon::App < Sinatra::Base

  set :haml, :format => :html5
  set :views,         ::File.expand_path('../../../haml', __FILE__)
  set :public_folder, ::File.expand_path('../../../public', __FILE__)

  helpers do
    include Rack::Utils
    include Redmon::RedisUtils

    def opts
      @opts
    end

    def count
      -(params[:count] ? params[:count].to_i : 1)
    end
  end

  def initialize(opts)
    @opts  = opts
    @redis = Redis.new(:url => opts[:redis_url])
    super(nil)
  end

  get '/' do
    haml :app
  end

  get '/info' do
    content_type :json
    @redis.zrange(info_key(@opts[:namespace]), count, -1).to_json
  end

  get '/cli' do
    args = params[:tokens].split
    cmd  = args.shift.downcase
    begin
      @result = @redis.send(cmd.intern, *args)
      @result = empty_result if @result == []
      haml :cli
    rescue ArgumentError
      wrong_number_of_arguments_for cmd
    rescue RuntimeError
      unknown cmd
    rescue Errno::ECONNREFUSED
      connection_refused_for @opts[:redis_url]
    end
  end

end