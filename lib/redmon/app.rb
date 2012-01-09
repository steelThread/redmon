class Redmon::App < Sinatra::Base
  set :haml, :format => :html5
  set :views,         ::File.expand_path('../../../haml', __FILE__)
  set :public_folder, ::File.expand_path('../../../public', __FILE__)

  helpers do
    include Rack::Utils

    def opts
      @opts
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
    @redis.zrange(Redmon.key, count, -1).to_json
  end

  get '/cli' do
    args = params[:tokens].split
    cmd  = args.shift.intern
    begin
      @result = @redis.send(cmd, *args)
    rescue
      @result = "(error) ERR wrong number of arguments for '#{cmd.to_s}' command"
    end
    haml :cli_result
  end

  def count
    -params[:count].to_i
  end
end