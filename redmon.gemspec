# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "redmon/version"

Gem::Specification.new do |s|
  s.name        = "redmon"
  s.version     = Redmon::VERSION
  s.authors     = ["Sean McDaniel"]
  s.email       = ["sean.mcdaniel@me.com"]
  s.homepage    = "https://github.com/steelThread/redmon"
  s.summary     = %q{Redis monitor}
  s.description = %q{Redis Admin interface and monitor.}

  s.rubyforge_project = "redmon"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = ["redmon"]
  s.require_paths = ["lib"]

  s.add_development_dependency 'bundler'
  s.add_development_dependency 'sinatra-contrib'
  s.add_development_dependency 'rack-test'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rake'

  s.add_dependency 'sinatra'
  s.add_dependency 'hiredis'
  s.add_dependency 'redis'
  s.add_dependency 'eventmachine'
  s.add_dependency 'i18n'
  s.add_dependency 'haml'
  s.add_dependency 'rack'
  s.add_dependency 'thin'
  s.add_dependency 'mixlib-cli'
  s.add_dependency 'json'
end
