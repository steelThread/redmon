require 'rubygems'
require 'json'
require 'rspec'
require 'redis'
require 'rack'
require 'rack/test'

ENV['RACK_ENV'] = "test"

$: << ::File.expand_path('../../lib', __FILE__)
require "redmon"
require "eventmachine"
require 'em-hiredis'