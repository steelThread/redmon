$: << ::File.expand_path("../../lib/", __FILE__)
require "rubygems"
require "bundler/setup"
require 'redmon'
require 'redis'

redis = Redis.connect

loop do
  start = rand(100000)
  multi = rand(5)
  start.upto(multi * start) do |i|
    redis.set("key-#{i}", "abcdedghijklmnopqrstuvwxyz")
  end

  start.upto(multi * start) do |i|
    redis.get("key-#{i}")
    redis.del("key-#{i}")
  end
end