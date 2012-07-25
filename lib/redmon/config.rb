module Redmon
  def self.configure
    yield config
  end

  def self.config
    @config ||= Config.new
  end

  class Config
    DEFAULTS = {
      :web_interface => ['0.0.0.0', 4567],
      :redis_url     => 'redis://127.0.0.1:6379',
      :namespace     => 'redmon',
      :worker        => true,
      :poll_interval => 10
    }

    attr_accessor(*DEFAULTS.keys)

    def initialize
      DEFAULTS.each { |k,v| send("#{k}=", v) }
    end

  end
end
