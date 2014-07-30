source "http://rubygems.org"

gemspec

gem "rake"

gem "sinatra", ">= 1.2.6"
gem "hiredis", "~> 0.4.0"
gem "redis", ">= 2.2.2"
gem "eventmachine"
gem "i18n"
gem "haml"
gem "rack"
gem "thin"
gem "activesupport", "~> 3.2.0"
# gem "json", "~> 1.7.7"
gem "mixlib-cli"

group :development do
  gem "sinatra-contrib", "~> 1.3.1"
  gem "rack-test"
end

group :test do
  gem "coveralls", :require => false
  gem "rspec", "~> 2.8.0"
end

platforms :ruby_18 do
  gem "mime-types", "~> 1.25"
end

platforms :rbx do
  gem "json"
  gem "racc"
  gem "rubinius-coverage", "~> 2.0"
  gem "rubysl", "~> 2.0"
  gem "psych"
end
