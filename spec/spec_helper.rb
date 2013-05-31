if ENV["TRAVIS"]
  require 'coveralls'
  Coveralls.wear!
else
  require 'simplecov'
  SimpleCov.start
end

require 'redmon'
require 'rack/test'

def mock_redis
  redis = double :redis
  Redis.stub(:connect).and_return(redis)
  redis
end