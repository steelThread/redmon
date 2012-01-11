$:.unshift File.expand_path('../../lib', __FILE__)
ENV['RACK_ENV'] = "test"

require "redmon"
require "eventmachine"
require 'em-hiredis'
require 'rack'
require 'redis'

require 'rspec'
require 'rack/test'
require 'delorean'

