Highcharts.setOptions({
   global: { useUTC: false }
});

var chart; // globally available
$(document).ready(function() {
  chart = new Highcharts.Chart({
    chart: {
      renderTo: 'container',
      defaultSeriesType: 'area',
	  events: {
	    load: requestData
	  }
    },
    title: {
      text: 'Redis Server Memory Usage'
    },
    xAxis: {type: 'datetime'},
    yAxis: {
      title: {text: 'Memory Used'}
    },
    legend: {
      enabled: true,
      borderWidth: 0
    },
    credits: {enabled: false},
	plotOptions: {
      area: {
        marker: {enabled: false}
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
      series.addPoint(point, true, series.data.length >= 50);
      setTimeout(requestData, 5000);
    }
  });
}