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
    thisgame.append_on_load_info("players", computePlayers);
  })

  /* *************************************************************************
   * computePlayers() is called at the very beginning of the page loading.
   *    It is here that the necessary data structures are built.
   *  This then calls:
   *     |
   *     +-->  initialize_players_and_squads()
   *             |     (this creates the HTML for the players/squads page,
   *             |      which is the default.)
   *            Which, in turn, calls:
   *             |
   *             +--> populate_player_list()
   *                      (this puts player scoreboard entries into the
   *                       placeholders made by the previous function.)
   */

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

    initialize_players_and_squads();
  }
});

/* **
 * Populate Player List should be run when the HTML for the scoreboard needs
 * to be generated initially. After that, update_player_list() will update only
 * the changed parts
 */
function populate_player_list() {
  thisgame.sort_players(function(a,b) { return b.score - a.score; })
  
  // If the user is logged in, show them on top of the leaderboard.
  if (thisgame.logged_in_user_id != null) {
    for (var i in thisgame.players_sorted) {
      if (thisgame.players_sorted[i].id == thisgame.logged_in_user_id) {
        $("div#logged_in_player").append(thisgame.players_sorted[i].get_scoreboard_html());
      }
    }
  }

  for (var i in thisgame.players_sorted) {
    if (i == "130") break;
    $("div#player_list").append(thisgame.players_sorted[i].get_scoreboard_html())
  }
  filter_players();

  thisgame.append_on_load_info("squads", function() {
    thisgame.load_squads()
    thisgame.sort_squads(function(a,b) { return b.score - a.score; })
    for (var i in thisgame.squads_sorted) {
      if (i == "30") break;
      $("div#squad_list").append(thisgame.squads_sorted[i].get_scoreboard_html())
    }
  })
} 
function update_player_list() {
    $("div#player_list").html("");
    for (var i in thisgame.players_sorted) {
      if (i == "30") break;
      $("div#player_list").append(thisgame.players_sorted[i].get_scoreboard_html())
    }
}
/* 
 * Zombie Tag Tree Builder
 *   Note: populate_zombie_tag_tree assumes that thisgame.retrieved_data["tags"] exists.
 *            (and also "info" and "players")
*/
function populate_zombie_tag_tree() {
  var tagdata = thisgame.retrieved_data["tags"];    // for convenience.
  var tags_by_tagger_id = {}
  for (var i in tagdata) {
    if (!(tagdata[i].tagger_id in tags_by_tagger_id)) {
      tags_by_tagger_id[tagdata[i].tagger_id] = []
    }
    tags_by_tagger_id[tagdata[i].tagger_id].push(tagdata[i])
  }

  var root_players = []
  for (var i in tagdata) {
    if (tagdata[i].administrative) {
      root_players.push(tagdata[i].tagged_id)
    }
  }
  for (var i in thisgame.players) {
    if (thisgame.players[i].is_oz) {
      root_players.push(thisgame.players[i].id)
    }
  }
  var children = []
  for (var i in root_players) {
    children.push( tag_tree_recursive(tags_by_tagger_id, root_players[i]) );
  }
  var tree = {id: "game", name: thisgame.name, data:{}, children: children};
  init_graph(tree)
}
// TODO: These variable names are really confusing.
function tag_tree_recursive(tags_by_tagger_id, tagger_id) {
  // If the player did not get any tags, return that player's info
  // and stop recursing.
  var p = thisgame.players_by_id[tagger_id];
  
  if (!(tagger_id in tags_by_tagger_id)) {
    return {id: "player" + p.id, name: p.name, data: {tags: 0}, children: []};
  }

  // For each tag this player got, recursively build the tree
  var children = []
  for (var i in tags_by_tagger_id[tagger_id]) {
    children.push( tag_tree_recursive(tags_by_tagger_id, tags_by_tagger_id[tagger_id][i].tagged_id) );
  }
  return {id: "player" + p.id, name: p.name, data: {tags: children.length}, children: children};
}

function initialize_players_and_squads() {
    var initialhtml = '<div id="content_players">' +
                        '<div id="sort_table"> Filter:' +
                           '<input type="text" size="30" name="filter[name]" id="filter_name"> Show:' +
                           '<select name="filter_faction" id="filter_faction">' +
                             '<option selected="selected">All</option>' +
                             '<option>Human</option>' + 
                             '<option>Zombie</option>' + 
                             '<option>Deceased</option>' +
                           '</select></div><div id="player_list"></div>' +
                      '</div>' + 
                      '<div id="content_squads">' +
                        '<h3 class="dink">Your Score</h3>' + 
                          '<div id="logged_in_player"></div>' +
                        '<h3 class="dink">Top Squads</h3>' +
                          '<div id="squad_list"></div>';
    $("#game_content").html(initialhtml);
    // Activate the filter features
    $("#filter_name, #filter_faction").bind("keyup change", filter_players);
    $("#filter_name").focus();
    var loc = window.location.hash;
    $("#filter_faction")[0].selectedIndex = 0;
    if (loc.indexOf("humans") != -1) {
      $("#filter_faction")[0].selectedIndex = 1;
    }
    if (loc.indexOf("zombies") != -1) {
      $("#filter_faction")[0].selectedIndex = 2;
    }
    if (loc.indexOf("deceased") != -1) {
      $("#filter_faction")[0].selectedIndex = 3;
    }
    thisgame.append_on_load_info("info", function() {
      thisgame.append_on_load_info("players", populate_player_list)
    })
}
function initialize_zombie_tag_tree() {
  $("#game_content").html("<h3 class='dink'>Zombie Tag Tree</h3><div id='gametree'></div><div id='log' style='height:32px'></div>");
  thisgame.append_on_load_info("tags", populate_zombie_tag_tree)
}
function filter_players() {
  var str = $("#filter_name")[0].value;
  var faction_filter = $("#filter_faction")[0].value;

  $("div#player_list").html("");
  if (str == "" && faction_filter == "All") {
    update_player_list();
    return;
  }
  for (var i in thisgame.players_sorted) {
    var p = thisgame.players_sorted[i]
    // Correct faction?
    if (p.faction.human_name == faction_filter || faction_filter == "All") {
      // Correct name substring?
      if (p.name.toLowerCase().indexOf(str.toLowerCase()) != -1) {
        $("div#player_list").append(thisgame.players_sorted[i].get_scoreboard_html())
      }
    }
  }
}
$(document).ready(function() {
  $("#players_and_squads_link").bind("click", initialize_players_and_squads);
  $("#zombie_tag_tree_link").bind("click", initialize_zombie_tag_tree);
})
