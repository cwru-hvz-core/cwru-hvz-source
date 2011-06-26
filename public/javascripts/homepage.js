$(document).ready(function() {
  thisgame.append_on_load_info("players", function() {
   
    thisgame.append_on_load_info("info", function() {
      // Update the "Game Statistics" box on the top right of the page
      thisgame.load_players();
      counts = {"0": 0, "1": 0, "2": 0};
      for (var i in thisgame.players) {
        if (!(thisgame.players[i].faction.key in counts)) {
          counts[thisgame.players[i].faction.key] = 0;
        }
        counts[thisgame.players[i].faction.key] += 1;
      }
      $("a#count_humans").html("Humans: " + counts["0"]);
      $("a#count_zombies").html("Zombies: " + counts["1"]);
      $("a#count_deceased").html("Deceased: " + counts["2"]);
      $("a#count_total").html("Total: " + thisgame.players.length);
    });

    // Update the "Recently Tagged" box on the bottom right
    thisgame.append_on_load_info("tags", function() {
      var t = thisgame.retrieved_data["tags"].sort( function(a,b) { return new Date(b.datetime) - new Date(a.datetime) } );
      $("ul#recently_tagged").html("");
      var i = 0;
      for (var tag in t) {
        $("ul#recently_tagged").append("<li><a href='/players/" + t[tag].tagged_id + "'>" + thisgame.players_by_id[t[tag].tagged_id].name + "</a></li>");
        i += 1;
        if (i >= 10 && (new Date(thisgame.now) - new Date(t[tag].datetime))/1000 > 3600) {
          break;
        }
      }
    });


  });
});
