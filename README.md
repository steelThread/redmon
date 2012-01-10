# Redmon

** Work in progress **
My personal administrative dashbord for redis.  After seeing [fnordmetric] project I was inspired to
write this.  I've wanting something like this for a while now.

----

Watch your redis server live.

![](http://dl.dropbox.com/u/27525257/dashboard.png)

----

Interact with your redis server using a familiar cli interface a la redis-cli.

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