module Redmon
  module Helpers
    include Redmon::Redis
    include Rack::Utils

    def url_path(*path_parts)
      [ path_prefix, path_parts ].join("/").squeeze('/')
    end
    alias_method :u, :url_path

    def path_prefix
      request.env['SCRIPT_NAME']
    end

    def prompt
      "#{redis_url.gsub('://', ' ')}>"
    end

    def poll_interval
      Redmon[:poll_interval] * 1000
    end

    def count
      -(params[:count] ? params[:count].to_i : 1)
    end

  end
end