module Redmon
  module Helpers
    include Redmon::Redis

    def prompt
      "#{redis_url.gsub('://', ' ')}>"
    end

    def poll_interval
      Redmon.config.poll_interval * 1000
    end

    def num_samples_to_request
      (Redmon.config.data_lifespan * 60) / Redmon.config.poll_interval
    end

    def count
      -(params[:count] ? params[:count].to_i : 1)
    end

    def absolute_url(path='')
      "#{uri(nil, false)}#{path.sub(%r{^\/+}, '')}"
    end

  end
end
