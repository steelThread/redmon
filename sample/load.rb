$: << ::File.expand_path("../../lib/", __FILE__)
require "rubygems"
require "bundler/setup"
require 'redmon'
require 'redis'

redis = Redis.connect

0.upto(1000000) do |i|
  redis.set("key-#{i}", "abcdedghijklmnopqrstuvwxyz")
end