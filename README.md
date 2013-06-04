[![Build status - Travis-ci](https://secure.travis-ci.org/steelThread/redmon.png) ](http://travis-ci.org/steelThread/redmon)
[![Code Climate](https://codeclimate.com/github/steelThread/redmon.png)](https://codeclimate.com/github/steelThread/redmon)
[![Gem Version](https://badge.fury.io/rb/redmon.png)](http://badge.fury.io/rb/redmon)
[![Coverage Status](https://coveralls.io/repos/steelThread/redmon/badge.png?branch=master)](https://coveralls.io/r/steelThread/redmon?branch=master)
# Redmon

Simple sinatra based dashbord for redis.  After seeing the [fnordmetric](https://github.com/paulasmuth/fnordmetric)
project I was inspired to write this.  Some of the ideas there have be carried over here.


----

Watch your redis server live.

![](http://dl.dropbox.com/u/27525257/dash-new.png)

----

Interact with redis using a familiar cli interface.

![](http://dl.dropbox.com/u/27525257/cli.png)

----

Dynamically update your server configuration.

![](http://dl.dropbox.com/u/27525257/configuration-new.png)

----

## Installation

Redmon is available as a RubyGem:

```bash
gem install redmon
```

## Usage

```bash
$ redmon -h
Usage: /Users/sean/codez/steelThread/redmon/vendor/ruby/1.9.1/bin/redmon (options)
    -a, --address ADDRESS            The thin bind address for the app (default: 0.0.0.0)
    -n, --namespace NAMESPACE        The root Redis namespace (default: redmon)
    -l, --lifespan MINUTES           Lifespan(in minutes) for polled data (default: 30)
    -i, --interval SECS              Poll interval in secs for the worker (default: 10)
    -p, --port PORT                  The thin bind port for the app (default: 4567)
    -r, --redis URL                  The Redis url for monitor (default: redis://127.0.0.1:6379)
    -s, --secure CREDENTIALS         Use basic auth. Colon separated credentials, eg admin:admin.
        --no-app                     Do not run the web app to present stats
        --no-worker                  Do not run a worker to collect the stats

$ redmon
>> Thin web server (v1.3.1 codename Triple Espresso)
>> Maximum connections set to 1024
>> Listening on 0.0.0.0:4567, CTRL+C to stop
[12-03-10 15:49:40] listening on http#0.0.0.0:4567
```

If you want to simulate a weak load on redis

```bash
$ ruby load_sim.rb
```

Open your browser to 0.0.0.0:4567

## Using in a Rails application

Add to Gemfile:

```ruby
gem 'redmon', require: false
```

Mount redmon in config/routes.rb:

```ruby
mount Redmon::App => '/redmon'
```

Create a config/initializers/redmon.rb file:

```ruby
require 'redmon/config'
require 'redmon/redis'
require 'redmon/app'

#
# Optional config overrides
#
Redmon.configure do |config|
  config.redis_url = 'redis://127.0.0.1:6379'
  config.namespace = 'redmon'
end
```

This will mount the Redmon application to the /redmon path.

### Stats worker

The worker that gathers the Redis info stats will not be started when Redmon is mounted like this. In order to get a EventMachine worker running inside your Rails app you can try this [Railtie based approach](https://github.com/steelThread/redmon/pull/19#issuecomment-7273659). If you are using a system to execute background tasks in your app (like Sidekiq, Resque, or Delayed Job), you can write your own worker to update the info stats.

A simple worker for Sidekiq looks like this:

```ruby
class RedmonWorker
  include Sidekiq::Worker

  def perform
    Redmon::Worker.new.record_stats
  ensure
    self.class.perform_in Redmon.config.poll_interval.seconds
  end
end
```

Once enqueued, the worker updates the stats and automatically enqueues itself to be performed again after the defined poll interval.

## Using with another Sinatra application

Create/Edit config.ru:

```ruby
require './app.rb'
require 'redmon'

map '/' do
  run Sinatra::Application
end
map '/redmon' do
  if EM.reactor_running?
    Redmon::Worker.new.run!
  else
    fork do
      trap('INT') { EM.stop }
      trap('TERM') { EM.stop }
      EM.run { Redmon::Worker.new.run! }
    end
  end

  run Redmon::App
end
```

In order to configure Redmon use this code in your app.rb file:

```ruby
Redmon.configure do |config|
  config.redis_url = 'redis://127.0.0.1:6379'
  config.namespace = 'redmon'
end
```

This will mount the Redmon application to the /redmon path.

## License

Copyright (c) 2012 Sean McDaniel

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to use, copy and modify copies of the Software, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
