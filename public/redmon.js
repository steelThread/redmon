Highcharts.setOptions({
   global: { useUTC: false }
});

var chart; // globally available
$(document).ready(load);

/**
 * Loads the last 100 events and starts the periodic polling for new events.
 */
function load() {
  request(100, function(data) {
    var points = [];
    data.forEach(function(info) {
      points.push([
	    parseInt(info.time),
		parseInt(info.used_memory)
	  ]);
    });
    render(points);
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
      var series = chart.series[0];
      series.addPoint(point, true, series.data.length >= 100);
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

/**
 * Render the dashboard.
 */
function render(data) {
  renderMemoryUsageChart(data);
};

function renderMemoryUsageChart(data) {
  chart = new Highcharts.Chart({
    chart: {
      renderTo: 'memory-container',
      defaultSeriesType: 'areaspline',
      zoomType: 'x'
    },
    title: {text: 'Live Memory Usage'},
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
    series: [{
      name: 'redis://localhost:6379',
      data: data
    }],
  });
};