Highcharts.setOptions({
   global: { useUTC: false }
});

var Redmon = (function() {
  var config,
      events = $({});

  /**
   * Loads the last 100 events and starts the periodic polling for new events.
   */
  function init(opts) {
    config = opts;
    nav.init();
    cli.init();
    requestData(100, function(data) {
      renderDashboard(data);
      poll();
    });
  }

  /**
   * Render the dashboard.
   */
  function renderDashboard(data) {
    memoryWidget.render(data);
    keyspaceWidget.render(data);
    infoWidget.render(data);
  }

  /**
   * Request the last {count} events.
   */
  function requestData(count, callback) {
    $.ajax({
      url: 'info?count='+count,
      success: function(data) {
        callback(
          data.map(function(info) {
            return $.parseJSON(info);
          })
        );
      }
    });
  }

  /**
   * Request data from the server, add it to the graph and set a timeout to request again
   */
  function poll() {
    requestData(1, function(data) {
      events.trigger('data', data[0]);
      setTimeout(poll, config.pollInterval);
    });
  }

  //////////////////////////////////////////////////////////////////////
  // encapsulate the keyspace chart
  var nav = (function() {
    var mapping = {};
    var current = {};

    function init() {
      ["dashboard", "cli", "config", "slow"].forEach(function(el) {
        mapping[el] = $('#'+el)
        mapping[el].click(onClick);
      });
      current.tab   = mapping.dashboard;
      current.panel = $('.viewport .dashboard');
    }

    function onClick(ev) {
      var tab = $(ev.currentTarget);
      if (!tab.hasClass('active')) {
        tab.addClass('active');
        current.tab.removeClass('active');

        var panel = $('.viewport .'+tab.attr('id'));
        current.panel.addClass('hidden');
        panel.removeClass('hidden').addClass('show');

        current = {tab: tab, panel: panel};
      }
    }

    return {
      init: init
    }
  })();

  //////////////////////////////////////////////////////////////////////
  // encapsulate the keyspace chart
  var memoryWidget = (function() {
    var chart;

    function render(data) {
      chart = new Highcharts.Chart({
        chart: {
          renderTo: 'memory-container',
          defaultSeriesType: 'areaspline',
          zoomType: 'x'
        },
        title: {text: ''},
        xAxis: {
          type: 'datetime',
          title: {text: null}
        },
        yAxis: {title: null},
        legend: {enabled: false},
        credits: {enabled: false},
        plotOptions: {
          line: {
            shadow: false,
            lineWidth: 3
          },
          series: {
            marker: {
              radius: 0,
              fillColor: '#FFFFFF',
              lineWidth: 2,
              lineColor: null
            },
            fillColor: {
              linearGradient: [0, 0, 0, 300],
              stops: [
                [0, 'rgb(69, 114, 167)'],
                [1, 'rgba(2,0,0,0)']
              ]
            }
          }
        },
        series: [{data: points(data)}],
      });
    }

    function points(data) {
      return data.map(point);
    }

    function point(info) {
      return [
        parseInt(info.time),
        parseInt(info.used_memory)
      ];
    }

    function onData(ev, data) {
      var series = chart.series[0];
      series.addPoint(point(data), true, series.data.length >= 25);
    }

    // observe data events
    events.bind('data', onData);

    return {
      render: render
    }
  })();

  //////////////////////////////////////////////////////////////////////
  // encapsulate the keyspace chart
  var keyspaceWidget = (function(){
    var chart;

    function render(data) {
      var hits = [],
        misses = [];
      points(data).forEach(function(point) {
        hits.push(point[0]);
        misses.push(point[1]);
      });

      chart = new Highcharts.Chart({
        chart: {
          renderTo: 'keyspace-container',
          defaultSeriesType: 'line'
        },
        title: {text: ''},
        xAxis: {
          type: 'datetime',
          title: {text: null}
        },
        yAxis: {title: null},
        legend: {
          layout: 'horizontal',
          align: 'top',
          verticalAlign: 'top',
          x: -5,
          y: -3,
          margin: 25,
          borderWidth: 0
        },
        credits: {enabled: false},
        plotOptions: {
          line: {
            shadow: false,
            lineWidth: 3
          },
          series: {
            marker: {
              radius: 0,
              fillColor: '#FFFFFF',
              lineWidth: 2,
              lineColor: null
            }
          }
        },
        series: [{
          name: 'Hits',
          data: hits
        },{
          name: 'Misses',
          data: misses
        }]
      });
    }

    function points(data) {
      return data.map(point);
    }

    function point(info) {
      var time = parseInt(info.time);
      return [
        [time, parseInt(info.keyspace_hits)],
        [time, parseInt(info.keyspace_misses)]
      ];
    }

    function onData(ev, data) {
      var newPoint = point(data);
      var hits = chart.series[0];
      hits.addPoint(newPoint[0], true, hits.data.length >= 25);

      var misses = chart.series[1];
      misses.addPoint(newPoint[1], true, misses.data.length >= 25);
    }

    // observe data events
    events.bind('data', onData);

    return {
      render: render
    }
  })();

  //////////////////////////////////////////////////////////////////////
  // encapsulate the info widget
  var infoWidget = (function() {

    function render(data) {
      updateTable(data[data.length-1]);
    }

    function onData(ev, data) {
      updateTable(data);
    }

    function updateTable(data) {
      $('#info-table td[id]').each(function() {
        var el = $(this),
         field = el.attr("id")
        if (data[field])
          el.text(data[field]);
      });
    }

    // observe data events
    events.bind('data', onData);

    return {
      render: render
    }
  })();

  //////////////////////////////////////////////////////////////////////
  // encapsulate the terminal emulator
  var cli = (function() {

    function init() {
      $('#wterm').wterm({
        WIDTH: '100%',
        HEIGHT: '500px',
        WELCOME_MESSAGE: "Welcome to redmon-cli. To Begin Using type <strong>help</strong>",
        PS1: config.cliPrompt
      });

      var command_directory = {
        'append'           : '/cli',
        "auth"             : '/cli',
        "bgrewriteaof"     : '/cli',
        "bgsave"           : '/cli',
        "blpop"            : '/cli',
        "brpop"            : '/cli',
        "brpoplpush"       : '/cli',
        "config get"       : '/cli',
        "config set"       : '/cli',
        "config resetstat" : '/cli',
        "dbsize"           : '/cli',
        "debug object"     : '/cli',
        "debug segfault"   : '/cli',
        "decr"             : '/cli',
        "decrby"           : '/cli',
        "del"              : '/cli',
        "discard"          : '/cli',
        "echo"             : '/cli',
        "exec"             : '/cli',
        "exists"           : '/cli',
        "expire"           : '/cli',
        "expireat"         : '/cli',
        "flushall"         : '/cli',
        "flushdb"          : '/cli',
        "get"              : '/cli',
        "getbit"           : '/cli',
        "getrange"         : '/cli',
        "getset"           : '/cli',
        "hdel"             : '/cli',
        "hexists"          : '/cli',
        "hget"             : '/cli',
        "hgetall"          : '/cli',
        "hincrby"          : '/cli',
        "hkeys"            : '/cli',
        "hlen"             : '/cli',
        "hmget"            : '/cli',
        "hmset"            : '/cli',
        "hset"             : '/cli',
        "hsetnx"           : '/cli',
        "hvals"            : '/cli',
        "incr"             : '/cli',
        "incrby"           : '/cli',
        "info"             : '/cli',
        "keys"             : '/cli',
        "lastsave"         : '/cli',
        "lindex"           : '/cli',
        "linsert"          : '/cli',
        "llen"             : '/cli',
        "lpop"             : '/cli',
        "lpush"            : '/cli',
        "lpushx"           : '/cli',
        "lrange"           : '/cli',
        "lrem"             : '/cli',
        "lset"             : '/cli',
        "ltrim"            : '/cli',
        "mget"             : '/cli',
        "monitor"          : '/cli',
        "move"             : '/cli',
        "mset"             : '/cli',
        "msetnx"           : '/cli',
        "multi"            : '/cli',
        "object"           : '/cli',
        "persist"          : '/cli',
        "publish"          : '/cli',
        "ping"             : '/cli',
        "quit"             : '/cli',
        "randomkey"        : '/cli',
        "rename"           : '/cli',
        "renamenx"         : '/cli',
        "rpop"             : '/cli',
        "rpoplpush"        : '/cli',
        "rpush"            : '/cli',
        "rpushx"           : '/cli',
        "sadd"             : '/cli',
        "save"             : '/cli',
        "scard"            : '/cli',
        "sdiff"            : '/cli',
        "sdiffstore"       : '/cli',
        "select"           : '/cli',
        "set"              : '/cli',
        "setbit"           : '/cli',
        "setex"            : '/cli',
        "setnx"            : '/cli',
        "setrange"         : '/cli',
        "shutdown"         : '/cli',
        "sinter"           : '/cli',
        "sinterstore"      : '/cli',
        "sismember"        : '/cli',
        "slaveof"          : '/cli',
        "smembers"         : '/cli',
        "smove"            : '/cli',
        "sort"             : '/cli',
        "spop"             : '/cli',
        "srandmember"      : '/cli',
        "srem"             : '/cli',
        "strlen"           : '/cli',
        "sunion"           : '/cli',
        "sunionstore"      : '/cli',
        "sync"             : '/cli',
        "ttl"              : '/cli',
        "type"             : '/cli',
        "watch"            : '/cli',
        "zadd"             : '/cli',
        "zcard"            : '/cli',
        "zcount"           : '/cli',
        "zincrby"          : '/cli',
        "zinterstore"      : '/cli',
        "zrange"           : '/cli',
        "zrangebyscore"    : '/cli',
        "zrank"            : '/cli',
        "zrem"             : '/cli',
        "zremrangebyrank"  : '/cli',
        "zremrangebyscore" : '/cli',
        "zrevrange"        : '/cli',
        "zrevrangebyscore" : '/cli',
        "zrevrank"         : '/cli',
        "zscore"           : '/cli',
        "zunionstore"      : '/cli',

        'strrev': {
          PS1: 'strrev $',

          EXIT_HOOK: function() {
            return 'exit interface commands';
          },

          START_HOOK: function() {
            return 'exit interface commands';
          },

          DISPATCH: function( tokens ) {
            return tokens.join('').reverse();
          }
        }
      };

      for( var j in command_directory ) {
        $.register_command( j, command_directory[j] );
      }

      $.register_command( 'help', function() {
        return 'redmon-cli supports a subset of the redis commands.' + '<br>' +
          'keys   - Find all keys matching the given pattern<br>' +
          'dbsize - Return the number of keys in the selected database<br>' +
          'set    - Set the string value of a key<br>' +
          'get    - Get the value of a key<br>' +
          'del    - Delete a key<br>' +
          'type   - Determine the type stored at key<br>'
      });
    }

    return {
      init: init
    }
  })();

  return  {
    init: init
  }
})();