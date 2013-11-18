$: << ::File.expand_path("../lib/", __FILE__)
require "rubygems"
require "bundler/setup"
require 'mixlib/cli'
require 'redmon'
require 'redis'

class RedmonLoadSimCLI
	include Mixlib::CLI

	option :redis_url,
		:short       => '-r URL',
		:long        => '--redis URL',
		:default     => 'redis://127.0.0.1:6379',
		:description => "The Redis url to load simulated traffic against (default: redis://127.0.0.1:6379, note: password is supported, ie redis://:password@127.0.0.1:6379)"

	def run
		parse_options
		
		redis_options = Redis::Client::DEFAULTS || {}
		redis_options[:url] = config[:redis_url] if config[:redis_url]
		redis = Redis.new(redis_options)

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
	end
end

RedmonLoadSimCLI.new.run
