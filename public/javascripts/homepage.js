$(document).ready(function() {
  thisgame.append_on_load_info("players", function() {
    thisgame.load_players();
    counts = {};
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
});
