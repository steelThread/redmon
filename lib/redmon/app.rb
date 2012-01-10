class Redmon::App < Sinatra::Base
  set :haml, :format => :html5
  set :views,         ::File.expand_path('../../../haml', __FILE__)
  set :public_folder, ::File.expand_path('../../../public', __FILE__)

  helpers do
    include Rack::Utils
    include RedisUtils

    def opts
      @opts
    end

    def count()
      -(params[:count] ? params[:count].to_i : 1)
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
    @redis.zrange(key, count, -1).to_json
  end

  get '/cli' do
    args = params[:tokens].split
    cmd  = args.shift.downcase.intern
    begin
      @result = @redis.send(cmd, *args)
      @result = '(empty list or set)' if @result == []
      haml :cli_result
    rescue
      "(error) ERR wrong number of arguments for '#{cmd.to_s}' command"
    end
  end

  private

    def key
      "#{@opts[:namespace]}:redis.info"
    end

end