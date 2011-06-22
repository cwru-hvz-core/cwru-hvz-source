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
  thisgame.append_on_load_info("info", function() {
    thisgame.append_on_load_info("players", computePlayers)
  })

  function computePlayers() {
    // If either the players or info data is not back yet, GTFO!
    if (!("info" in thisgame.retrieved_data) ||
                            !("players" in thisgame.retrieved_data)) {
      return;
    }
    
    // Initialize all Players and calculate some nice things
    //   like the total score and current faction.
    thisgame.load_players()
    
    //////////////////////////////////////////////////////////////////////////
    // Calculate number of humans/zombies/deceased
    //////////////////////////////////////////////////////////////////////////
    var factions = {}
    var ozs = []
    for (var i in thisgame.players) {
      var f = thisgame.players[i]
      if (!(f.faction["key"] in factions)) {
        factions[f.faction["key"]] = 0
      }
      factions[f.faction["key"]] += 1

      if (f.is_oz == true) {
        ozs.push(f)
      }
    }
    $("td#human_count").html(factions[0]);
    $("td#zombie_count").html(factions[1]);
    $("td#deceased_count").html(factions[2]);
    $("td#total_count").html(thisgame.players.length);
   
    ////////////////////////////////////////////////////////////////////////// 
    // Add the OZs to the OZ table.
    //////////////////////////////////////////////////////////////////////////
    ozs.sort(function(a,b) { return b["score"] - a["score"] });
    $("tbody#ozs").html("");
    for (var i in ozs) {
      $("tbody#ozs").append("<tr><td>" + ozs[i]["name"] + "</td><td>" + ozs[i]["static_score"] + "</tr>");
    }

    //////////////////////////////////////////////////////////////////////////
    // Create the graph.
    //////////////////////////////////////////////////////////////////////////
    var human, zombie, deceased
    begin_date = new Date(thisgame["game_begins"]);
    end_date = new Date(thisgame["game_ends"]);
    var granularity = 250
    delta = (end_date - begin_date) / granularity;
    var time_data = {}
    for (i=0; i < granularity; i++) {
      var now = new Date(begin_date.getTime() + delta * i);
      time_data[now] = {"-1": 0, "0": 0, "1": 0, "2": 0};
      for (var j in thisgame.players) {
        var f = thisgame.players[j].get_faction_at(now)
        time_data[now][f["key"]] += 1
      }
    }
    human = Object.keys(time_data).map(function(k) { return [(new Date(k)).getTime(), time_data[k]["0"]] })
    zombie = Object.keys(time_data).map(function(k) { return [(new Date(k)).getTime(), time_data[k]["1"]] })
    deceased = Object.keys(time_data).map(function(k) { return [(new Date(k)).getTime(), time_data[k]["2"]] })
    options.series[0].data = human;
    options.series[1].data = zombie;
    options.series[2].data = deceased;
    chart = new Highcharts.Chart(options);

    //////////////////////////////////////////////////////////////////////////
    // Populate the scoreboard
    //////////////////////////////////////////////////////////////////////////
    thisgame.sort_players(function(a,b) { return b.score - a.score; })
    for (var i in thisgame.players_sorted) {
      if (i == "130") break;
      $("div#player_list").append(thisgame.players_sorted[i].get_scoreboard_html())
    }

    thisgame.append_on_load_info("squads", function() {
      thisgame.load_squads()
      thisgame.sort_squads(function(a,b) { return b.score - a.score; })
      for (var i in thisgame.squads_sorted) {
        if (i == "30") break;
        $("div#squad_list").append(thisgame.squads_sorted[i].get_scoreboard_html())
      }
    })
  }
  
  var alpha = function() {
      thisgame.sort_players(function(a,b) { if (b.name < a.name) { return 1 }; 
        if (b.name > a.name) { return -1 }; 
        return 0; 
      }, true)
      update_player_list()
    $("#alphabetize").unbind("click", alpha)
    $("#alphabetize").bind("click", unalpha)
  }
  var unalpha = function() {
    thisgame.sort_players(function(a,b) { return b.score - a.score; }) 
    update_player_list();
    $("#alphabetize").bind("click", alpha)
    $("#alphabetize").unbind("click", unalpha)
  }
  $("#alphabetize").bind("click", alpha)

});
function update_player_list() {
    $("div#player_list").html("");
    for (var i in thisgame.players_sorted) {
      if (i == "30") break;
      $("div#player_list").append(thisgame.players_sorted[i].get_scoreboard_html())
    }
}
