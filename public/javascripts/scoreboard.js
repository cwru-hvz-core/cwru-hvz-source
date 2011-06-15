
var chart;
$(document).ready(function() {
  
  // define the options
  var options = {
    chart: {
      height: 140,
      defaultSeriesType: 'line',
      renderTo: 'graph',
      margin: [10, 0, 10, 30]
    },

    credits: {
      enabled: false
    },
 
    title: {
      text: null
    },
    
    
    xAxis: {
      type: 'datetime',
      tickInterval: 24 * 3600 * 1000, // one day
      tickWidth: 0,
      gridLineWidth: 1,
      labels: {
        enabled: false,
        align: 'left',
        x: 3,
        y: 3 
      }
    },

    yAxis: { // left y axis
      title: {
        text: null
      },
      tickInterval: 25,
      offset: 0,
      labels: {
        align: 'right',
        formatter: function() {
          return Highcharts.numberFormat(this.value, 0);
        }
      },
      min: 0
    },
    
    legend: {
      enabled: false
    },
    
    tooltip: {
      shared: true,
      crosshairs: true
    },
    
    plotOptions: {
      series: {
        cursor: 'pointer',
        point: {
        },
        marker: {
          lineWidth: 1
        }
      }
    },
    
    series: [{
      name: 'Humans',
      lineWidth: 2,
      marker: {
        radius: 0
      }
    }, {
      name: 'Zombies',
      lineWidth: 2,
      marker: { radius: 0 }
    }, {
      name: 'Deceased',
      lineWidth: 2,
      marker: { radius: 0 }
    }]
  }
  
  // Load data asynchronously using jQuery. On success, add the data
  // to the options and initiate the chart.
  jQuery.get('/api/game/1?type=players', null, function(data) {
    console.log(data.length)
    $("#game_content").html(data.toString());
    var lines = [],
      listen = false,
      date,
      
      // set up the two data series
      time_data = []
 
      jQuery.get('/api/game/1?type=info', null, function(data2) {
        var human, zombie, deceased
        begin_date = new Date(data2["game_begins"]);
        end_date = new Date(data2["game_ends"]);
        delta = (end_date - begin_date) / 400;
        for (i=0; i < 400; i++) {
          now = new Date(begin_date.getTime() + delta * i);
          time_data[now] = {"zombie": 0, "human": 0, "deceased": 0};
          for (var j in data) {
            state_human = data[j]["state_history"]["human"]
            state_zombie = data[j]["state_history"]["zombie"]
            state_deceased = data[j]["state_history"]["deceased"]
            if (new Date(state_human) <= now) {
              if (new Date(state_zombie) <= now) {
                if (new Date(state_deceased) <= now) {
                  time_data[now]["deceased"] += 1
                  continue
                }
                time_data[now]["zombie"] += 1
                continue
              }
              time_data[now]["human"] += 1
            }
          }
        }
        human = Object.keys(time_data).map(function(k) { return [(new Date(k)).getTime(), time_data[k]["human"]] })
        zombie = Object.keys(time_data).map(function(k) { return [(new Date(k)).getTime(), time_data[k]["zombie"]] })
        deceased = Object.keys(time_data).map(function(k) { return [(new Date(k)).getTime(), time_data[k]["deceased"]] })
        options.series[0].data = human;
        options.series[1].data = zombie;
        options.series[2].data = deceased;
        chart = new Highcharts.Chart(options);
      })
   }) 
});
