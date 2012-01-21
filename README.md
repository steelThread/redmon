# Redmon

** Work in progress in the very early stages of dev **

Simple sinatra based dashbord for redis.  After seeing the [fnordmetric](https://github.com/paulasmuth/fnordmetric)
project I was inspired to write this.  Some of the ideas there have be carried over here.

[ ![Build status - Travis-ci](https://secure.travis-ci.org/steelThread/redmon.png) ](http://travis-ci.org/steelThread/redmon)

----

Watch your redis server live.

![](http://dl.dropbox.com/u/27525257/dash-new.png)

----

Interact with redis using a familiar cli interface.

![](http://dl.dropbox.com/u/27525257/cli-new.png)

----

Dynamically update your server configuration.

![](http://dl.dropbox.com/u/27525257/configuration-new.png)

----

Intuitively introspect registered keys.  ** Coming Soon **

----

## Usage
Currently not a registered gem, but soon.  For now clone the repo &

```bash
$ bundle install
$ ruby sample/app.rb
```

If you want to simulate a weak load on redis

```bash
$ ruby sample/load_sim.rb
```

Open your browser to 0.0.0.0:4567