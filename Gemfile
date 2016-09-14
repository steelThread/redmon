source "http://rubygems.org"

gemspec

group :test do
  gem "coveralls", :require => false
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
