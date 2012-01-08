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
  var memoryWidget = (function() {
    var chart;

    function render(data) {
      chart = new Highcharts.Chart({
        chart: {
          renderTo: 'memory-container',
          defaultSeriesType: 'areaspline',
          zoomType: 'x'
        },
        title: {text: 'Memory Usage'},
        xAxis: {
          type: 'datetime',
          tickPixelInterval: 150,
          title: {text: null}
        },
        yAxis: {title: null},
        legend: {enabled: false},
        credits: {enabled: false},
        plotOptions: {
          series: {
            lineWidth: 1,
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
      series.addPoint(point(data), true, series.data.length >= 100);
    }

    // observe update events
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
          defaultSeriesType: 'spline'
        },
        title: {text: 'Keyspace Hits/Misses'},
        xAxis: {
          type: 'datetime',
          tickPixelInterval: 150,
          title: {text: null}
        },
        yAxis: {title: null},
        legend: {
          layout: 'vertical',
          align: 'right',
          verticalAlign: 'top',
          x: -10,
          y: 100,
          borderWidth: 0
        },
        credits: {enabled: false},
        plotOptions: {
          series: {
            lineWidth: 2,
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
      hits.addPoint(newPoint[0], true, hits.data.length >= 100);

      var misses = chart.series[1];
      misses.addPoint(newPoint[1], true, misses.data.length >= 100);
    }

    // observe update events
    events.bind('data', onData);

    return {
      render: render
    }
  })();

  return  {
    init: init
  }
})();