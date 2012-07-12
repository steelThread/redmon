module Redmon
  class App < Sinatra::Base

    helpers Redmon::Helpers

    get '/' do
      haml :app
    end

    get '/cli' do
      args = params[:command].split
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
      if path_prefix
        @worker ||= Worker.new
        @worker.record_stats
      end
      redis.zrange(stats_key, count, -1).to_json
    end

  end
end