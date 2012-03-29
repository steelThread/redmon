require 'redmon'
require 'rack/test'

def mock_redis
  redis = double :redis
  Redis.stub(:connect).and_return(redis)
  redis
end