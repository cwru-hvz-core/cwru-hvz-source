function whichState(now, stateHistory) {
  var now = new Date(now);
  var human = new Date(stateHistory["human"]);
  var zombie = new Date(stateHistory["zombie"]);
  var deceased = new Date(stateHistory["deceased"]);
  if (human < now) {
    if (zombie < now) {
      if (deceased < now) {
        return {"faction_id": 2, "class_name": "deceased", "human_name": "Deceased"};
      }
      return {"faction_id": 1, "class_name": "zombie", "human_name": "Zombie"};
    }
    return {"faction_id": 0, "class_name": "human", "human_name": "Human"};
  }
}
var chart;
$(document).ready(function() {
  
  // Set up the MagicLine
    var $el, leftPos, newWidth,
        $mainNav = $("#view_links");

    $mainNav.append("<li id='magic-line'></li>");
    var $magicLine = $("#magic-line");

    $magicLine
        .width($(".current_page_item").width())
        .css("left", $(".current_page_item a").position().left)
        .data("origLeft", $magicLine.position().left)
        .data("origWidth", $magicLine.width());

    $("#view_links li a").hover(function() {
        $el = $(this);
        leftPos = $el.position().left;
        newWidth = $el.parent().width();
        $magicLine.stop().animate({
            left: leftPos,
            width: newWidth
        });
    }, function() {
        $magicLine.stop().animate({
            left: $magicLine.data("origLeft"),
            width: $magicLine.data("origWidth")
        });
    });
///////////////////////////////////////////////////////////
  // define the options
  var options = {
    chart: {
      height: 140,
      defaultSeriesType: 'line',
      renderTo: 'graph',
      margin: [10, 0, 10, 30]
    },
    colors: [ "#2255AA", "#5EC24D", "#999999" ],

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
  jQuery.getJSON('/api/game/1/players', null, function(data) {
      
      // Calculate number of humans/zombies/deceased
      var factions = [];
      var ozs = [];
      for (var j in data) {
        if (factions[data[j]["current_faction"]] == null) {
          factions[data[j]["current_faction"]] = 0
        }
        factions[data[j]["current_faction"]] += 1

        if (data[j]["is_oz"] == true) {
          ozs.push(data[j])
        }
      }
      $("td#human_count").html(factions[0]);
      $("td#zombie_count").html(factions[1]);
      $("td#deceased_count").html(factions[2]);
      $("td#total_count").html(data.length);
      
      // Add the OZs to the OZ table.
      ozs.sort(function(a,b) { return b["score"] > a["score"] });
      $("tbody#ozs").html("");
      for (var i in ozs) {
        $("tbody#ozs").append("<tr><td>" + ozs[i]["name"] + "</td><td>" + ozs[i]["score"] + "</tr>");
      }
      // set up the two data series
      var time_data = [];
      
      jQuery.getJSON('/api/game/1/info', null, function(data2) {
      //////////////////////////////////////////////////////
      // Before we get into the graph stuff, populate the
      // scoreboard....
      //////////////////////////////////////////////////////

      // Add players to the scoreboard
      best = data.sort(function(a,b) { return b["score"] > a["score"]; });
      for (var i = 1; i < 11; i++) {
        // i is the rank, so i - 1 is the array index
        player = data[i-1];             // (for convenience)
        state = whichState(data2["now"], player["state_history"]);
        // Creating the container
        j = document.createElement("div");
        j.classList.add("player");
        j.classList.add(state["class_name"])
        if (player["is_admin"] == true) { j.classList.add("admin") }
        // Create the rank
        k = document.createElement("span");
        k.classList.add("rank");
        k.innerHTML = i;
        j.appendChild(k);
        // Create the name
        k = document.createElement("span");
        k.classList.add("name");
        k.innerHTML = player["name"];
        j.appendChild(k);
        // Create the points/score
        // TODO: Make the verbiage consistent - points vs. score
        k = document.createElement("span");
        k.classList.add("points");
        k.innerHTML = player["score"] + " pts";
        j.appendChild(k);
        // Create the faction
        k = document.createElement("span");
        k.classList.add("faction");
        k.innerHTML = state["human_name"];
        j.appendChild(k);
        // Create the status
        k = document.createElement("span");
        k.classList.add("status");
        k.innerHTML = "We'll figure this out later.";
        j.appendChild(k);
        $("div#content_players").append(j);
      }


      //////////////////////////////////////////////////////
      // Graph Stuff Here!
      //////////////////////////////////////////////////////
        var human, zombie, deceased
        begin_date = new Date(data2["game_begins"]);
        end_date = new Date(data2["game_ends"]);
        var granularity = 250
        delta = (end_date - begin_date) / granularity;
        for (i=0; i < granularity; i++) {
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
