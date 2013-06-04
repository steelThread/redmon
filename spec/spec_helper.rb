require 'simplecov'
require 'coveralls'

if ENV["TRAVIS"]
  SimpleCov.formatter = Coveralls::SimpleCov::Formatter
end

SimpleCov.start do
  add_filter '/spec/'
end

require 'redmon'
require 'rack/test'

def mock_redis
  redis = double :redis
  Redis.stub(:connect).and_return(redis)
  redis
end