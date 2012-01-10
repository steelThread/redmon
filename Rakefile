require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'rspec'
require 'rspec/core/rake_task'
desc "Run all examples"
task RSpec::Core::RakeTask.new('spec')

task :default => "spec"
