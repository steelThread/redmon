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

  s.add_development_dependency 'bundler', '~> 1.3'
  s.add_development_dependency 'sinatra-contrib', '~> 1.3.1'
  s.add_development_dependency 'rack-test'
  s.add_development_dependency 'rspec', '~> 2.8.0'
  s.add_development_dependency 'rake'
  
  s.add_dependency 'sinatra', '>= 1.2.6'
  s.add_dependency 'hiredis', '~> 0.4.0'
  s.add_dependency 'redis', '>= 2.2.2'
  s.add_dependency 'eventmachine'
  s.add_dependency 'i18n'
  s.add_dependency 'haml'
  s.add_dependency 'rack'
  s.add_dependency 'thin'
  s.add_dependency 'mixlib-cli'
end
