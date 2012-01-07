Highcharts.setOptions({
   global: { useUTC: false }
});

var chart; // globally available
$(document).ready(function() {
  chart = new Highcharts.Chart({
    chart: {
      renderTo: 'memory-container',
      defaultSeriesType: 'areaspline',
      zoomType: 'x',
	  events: {
	    load: requestData
	  }
    },
    title: {
      text: 'Memory Used'
    },
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
		  radius: 2,
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
      data: []
    }],
  });
});

/**
 * Request data from the server, add it to the graph and set a timeout to request again
 */
function requestData() {
  $.ajax({
    url: 'info',
    dataType: 'json',
    success: function(result) {
	  var point = [
	    new Date().getTime(),
		parseInt(result.used_memory)
	  ];

      console.log(parseInt(result.used_memory));
      var series = chart.series[0];
      series.addPoint(point, true, series.data.length >= 60);
      setTimeout(requestData, 5000);
    }
  });
}