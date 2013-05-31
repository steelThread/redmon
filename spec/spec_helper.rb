require 'redmon'
require 'rack/test'
require 'coveralls'

Coveralls.wear!

def mock_redis
  redis = double :redis
  Redis.stub(:connect).and_return(redis)
  redis
end