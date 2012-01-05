var chart1; // globally available
$(document).ready(function() {
  chart1 = new Highcharts.Chart({
    chart: {
      renderTo: 'container',
      type: 'bar'
    },
    title: {
      text: 'Fruit Consumption'
    },
    xAxis: {
      categories: ['Apples', 'Bananas', 'Oranges']
    },
    yAxis: {
      title: {
        text: 'Fruit eaten'
      }
    },
    series: [{
      name: 'Jane',
      data: [1, 0, 4]
    },{
      name: 'John',
      data: [5, 7, 3]
    }]
  });
});