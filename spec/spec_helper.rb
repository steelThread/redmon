$:.unshift File.expand_path('../../lib', __FILE__)
ENV['RACK_ENV'] = "test"

require "redmon"
require "eventmachine"
require 'rack'
require 'redis'

require 'rspec'
require 'rack/test'

def mock_redis
  redis = double :redis
  Redis.stub(:connect).and_return(redis)
  redis
end

