# Redmon

** Work in progress **
Simple sinatra based dashbord for redis.  After seeing the [fnordmetric](https://github.com/paulasmuth/fnordmetric)
project I was inspired to write this.  Some of the ideas there have be carried over here.

----

Watch your redis server live.

![](http://dl.dropbox.com/u/27525257/dashboard.png)

----

Interact with redis using a familiar cli interface.

![](http://dl.dropbox.com/u/27525257/cli.png)

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