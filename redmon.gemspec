# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "redmon/version"

Gem::Specification.new do |s|
  s.name        = "redmon"
  s.version     = Redmon::VERSION
  s.authors     = ["Sean McDaniel"]
  s.email       = ["sean.mcdaniel@me.com"]
  s.homepage    = ""
  s.summary     = %q{Redis monitor}
  s.description = %q{Redis Admin interface and monitor.}

  s.rubyforge_project = "redmon"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec"
end
