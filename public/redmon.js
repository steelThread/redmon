Highcharts.setOptions({
   global: { useUTC: false }
});

var Redmon = (function() {

  /**
   * Loads the last 100 events and starts the periodic polling for new events.
   */
  function init(opts) {
    requestData(100, function(data) {
	  renderDashboard(data);
      poll();
    });
  }

  /**
   * Render the dashboard.
   */
  function renderDashboard(data) {
    memoryChart.render(data);
    keyspaceChart.render(data);
  }

  /**
   * Request the last {count} events.
   */
  function requestData(count, callback) {
    $.ajax({
      url: 'info?count='+count,
      success: function(data) {
	    var decoded = []
	    data.forEach(function(info) {
	      decoded.push($.parseJSON(info));
	    });
	    callback(decoded);
      }
    });
  }

  /**
   * Request data from the server, add it to the graph and set a timeout to request again
   */
  function poll() {
    requestData(1, function(data) {
	  memoryChart.update(data);
      keyspaceChart.update(data);
      setTimeout(poll, 5000);
    });
  }

  //////////////////////////////////////////////////////////////////////
  // encapsulate the keyspace chart
  var memoryChart = (function() {
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

    function update(data) {
      var series = chart.series[0];
	  var point = points(data)[0]
      series.addPoint(point, true, series.data.length >= 100);
    }

    function points(data) {
      var points = [];
      data.forEach(function(info) {
        points.push([
          parseInt(info.time),
          parseInt(info.used_memory)
        ]);
      });

      return points;
    }

    return {
	  render: render,
	  update: update
    }
  })();


  //////////////////////////////////////////////////////////////////////
  // encapsulate the keyspace chart
  var keyspaceChart = (function(){
    var chart;

    function render(data) {
      var hits = [],
        misses = [];
      var points = keyspacePoints(data);
      points.forEach(function(point) {
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

    function update(data) {
  	  data.forEach(function(info) {
  	    var time = parseInt(info.time);
        var hit  = [time, parseInt(info.keyspace_hits)];
        var hits = chart.series[0];
        hits.addPoint(hit, true, hits.data.length >= 100);

        var misses = chart.series[1];
        var miss   = [time, parseInt(info.keyspace_misses)];
        misses.addPoint(miss, true, misses.data.length >= 100);
      });
    }

    function keyspacePoints(data) {
      var points = [];
      data.forEach(function(info) {
  	    var time = parseInt(info.time);
        points.push([
          [time, parseInt(info.keyspace_hits)],
          [time, parseInt(info.keyspace_misses)]
        ]);
      });

      return points;
    }

    return {
	  render: render,
	  update: update
    }
  })();

  return  {
    init: init
  }
})();