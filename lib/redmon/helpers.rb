module Redmon
  module Helpers
    include Redmon::Redis

    def prompt
      "#{redis_url.gsub('://', ' ')}>"
    end

    def poll_interval
      Redmon.config.poll_interval * 1000
    end

    def count
      -(params[:count] ? params[:count].to_i : 1)
    end

    def absolute_url path = ''
      uri = uri(nil, false).sub(%r{\/$}, '')
      path.sub!(%r{^\/+}, '')
      
      "#{url}/#{path}"
    end

  end
end
