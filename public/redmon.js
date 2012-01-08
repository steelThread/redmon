Highcharts.setOptions({
   global: { useUTC: false }
});

var Redmon = (function() {
  var memoryChart, keyspaceChart;

  /**
   * Loads the last 100 events and starts the periodic polling for new events.
   */
  function init() {
    request(100, function(data) {
	  render(data);
      poll();
    });
  }

  /**
   * Request data from the server, add it to the graph and set a timeout to request again
   */
  function poll() {
    request(1, function(data) {
  	  data.forEach(function(info) {
        var point = [
          parseInt(info.time),
          parseInt(info.used_memory)
        ];
        var series = memoryChart.series[0];
        series.addPoint(point, true, series.data.length >= 100);

  	    var time = parseInt(info.time);
        var hit  = [time, parseInt(info.keyspace_hits)];
        var hits = keyspaceChart.series[0];
        hits.addPoint(hit, true, hits.data.length >= 100);

        var misses = keyspaceChart.series[1];
        var miss   = [time, parseInt(info.keyspace_misses)];
        misses.addPoint(miss, true, misses.data.length >= 100);
	  });
      setTimeout(poll, 5000);
    });
  }

  /**
   * Request the last {count} events.
   */
  function request(count, callback) {
    $.ajax({
      url: 'info?count='+count,
      success: function(response) {
	    var data = []
	    response.forEach(function(result) {
	      data.push($.parseJSON(result));
	    });
	    callback(data);
      }
    });
  }

  function memoryPoints(data) {
    var points = [];
    data.forEach(function(info) {
      points.push([
        parseInt(info.time),
        parseInt(info.used_memory)
      ]);
    });

    return points;
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

  /**
   * Render the dashboard.
   */
  function render(data) {
    renderMemoryUsageChart(data);
    renderKeyspaceChart(data);
  }

  function renderMemoryUsageChart(data) {
    memoryChart = new Highcharts.Chart({
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
      series: [{data: memoryPoints(data)}],
    });
  };

  function renderKeyspaceChart(data) {
    var hits = [],
      misses = [];
    var points = keyspacePoints(data);
    points.forEach(function(point) {
      hits.push(point[0]);
      misses.push(point[1]);
    });

    keyspaceChart = new Highcharts.Chart({
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

  return  {
    init: init
  }
})();