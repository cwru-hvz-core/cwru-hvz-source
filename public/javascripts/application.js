// On every page, maintain a frontend Game object. Any frontend
// component can query this for a part of the game state. This
// should minimize variable scope issues as well as minimize the
// number of page requests.

var Game = function(params) {

  this.game_id = params["id"]
  this.logged_in_user_id = params["logged_in_user_id"]
  this.retrieved_data = {}

  ////////////////////////////////////////////////////////////////////////////
  //
  //   Game info AJAX downloader.
  //
  ////////////////////////////////////////////////////////////////////////////
  this.get_game_info = function(url, callback) {
      jQuery.getJSON("/api/game/" + this.game_id + "/" + url, 
      jQuery.proxy(function(data) {
        this.retrieved_data[url] = data
        this.on_load_info(url)
      }, this))
  }
  this.onload_chains = {}
  this.on_load_info = function(url) {
    // Call all functions in the onload_chain
    for (var j in this.onload_chains[url]) {
      this.onload_chains[url][j]()
    }
  }
  this.append_on_load_info = function(url, callback) {
    // If we have the data already, just execute the callback funciton.
    if (url in this.retrieved_data) {
      callback()
    }

    // If this is the first time asking for this data, create an onload_chain
    // for that data URL.
    if (!(url in this.onload_chains)) {
      this.onload_chains[url] = []
    }

    this.onload_chains[url].push(callback)

    if (this.onload_chains[url].length == 1) {
      this.get_game_info(url)
    }
  }
  ////////////////////////////////////////////////////////////////////////////
  this.players = []
  this.players_by_id = {}
  this.load_players = function() {
    for (var i in this.retrieved_data["players"]) {
      var one = new Player(this.retrieved_data["players"][i])

      if ("info" in this.retrieved_data) {
        one.set_state_at(this.retrieved_data["info"]["now"], 
                      this.retrieved_data["info"]["points_per_hour"])
      }
      this.players.push(one)
      this.players_by_id[one.id] = one
    }
  }
  this.sort_players = function(sort_method, dont_renumber) {
    this.players_sorted = this.players.sort(sort_method)
    if (dont_renumber == null || dont_renumber == false) {
      for (var i in this.players_sorted) {
        this.players_sorted[i].rank = parseInt(i)+1
      }
    }
  }
  ////////////////////////////////////////////////////////////////////////////
  this.squads = []
  this.squads_by_id = {}
  this.load_squads = function() {
    for (var i in this.retrieved_data["squads"]) {
      var one = new Squad(this.retrieved_data["squads"][i])

      this.squads.push(one)
      this.squads_by_id[one.id] = one
    }
  }
  this.sort_squads = function(sort_method, dont_renumber) {
    this.squads_sorted = this.squads.sort(sort_method)
    if (dont_renumber == null || dont_renumber == false) {
      for (var i in this.squads_sorted) {
        this.squads_sorted[i].rank = parseInt(i)+1
      }
    }
  }
}
var factions = { 
  "-1": {"human_name": "Unknown", "class_name": "", "key": "-1"},
  "0": {"human_name": "Human", "class_name": "human", "key": "0"},
  "1": {"human_name": "Zombie", "class_name": "zombie", "key": "1"},
  "2": {"human_name": "Deceased", "class_name": "deceased", "key": "2"}
}
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
var Player = function(data) {
  this.state_history = data["state_history"]
  this.id = data["id"]
  this.name = data["name"]
  this.static_score = data["static_score"]
  this.is_oz = data["is_oz"]
  this.is_admin = data["is_admin"]
  this.faction = factions[-1]

  /////////////////////////////////////
  // Determine the player's state and point total at a given time.
  /////////////////////////////////////
  this.set_state_at = function(game_now, points_per_hour) {
    var time_alive = (new Date(this.state_history["zombie"])) - (new Date(this.state_history["human"]))
    var time_points = points_per_hour * (time_alive/3600000)
    this.score = this.static_score + time_points
    this.faction = this.get_faction_at(new Date(game_now))
  }

  this.get_faction_at = function(now) {
    var human = new Date(this.state_history["human"]);  
    var zombie = new Date(this.state_history["zombie"]);  
    var deceased = new Date(this.state_history["deceased"]);
    if (human <= now) {    
      if (zombie < now) {      
        if (deceased < now) {        
          return factions[2]
        } 
        return factions[1]  
      }    
      return factions[0]
    }
  }

  this.get_scoreboard_html = function() {
    // Creating the container
    j = document.createElement("div");
    j.classList.add("player");
    j.classList.add(this.faction.class_name)
    if (this.is_admin == true) { j.classList.add("admin") }
    // Create the rank
 //   k = document.createElement("span");
 //   k.classList.add("rank");
 //   k.innerHTML = this.rank;
 //  j.appendChild(k);
    k = document.createElement("span");
    k.classList.add("pic");
    k.innerHTML = "<img src='http://tomdooner.com:3000/images/nerf-raider.jpg' width='32' height='32'>";
    j.appendChild(k);
    // Create the name
    k = document.createElement("span");
    k.classList.add("name");
    k.innerHTML = this.name;
    j.appendChild(k);
    // Create the points/score
    // TODO: Make the verbiage consistent - points vs. score
    k = document.createElement("span");
    k.classList.add("points");
    k.innerHTML = Math.round(this.score) + " pts";
    j.appendChild(k);
    // Create the faction
    k = document.createElement("span");
    k.classList.add("faction");
    k.innerHTML = this.faction.human_name;
    j.appendChild(k);
    // Create the status
    k = document.createElement("span");
    k.classList.add("status");
    k.innerHTML = "Ranked " + this.rank + "th with [accomplishments]";
    j.appendChild(k);
    return j
  }
}
var Squad = function(data) {
  this.id = data.id
  this.leader_id = data.leader_id
  this.name = data.name
  this.members_id = data.members
  this.members = []
  this.score = 0
  if (this.leader_id in thisgame.players_by_id) {
    this.leader = thisgame.players_by_id[this.leader_id]
  }
  for (var i in this.members_id) {
    if (this.members_id[i] in thisgame.players_by_id) {
      this.members.push(thisgame.players_by_id[this.members_id[i]])
    }
  }
  for (var i in this.members) {
    this.score += this.members[i].score
  }

  // TODO: Eventually, differentiate this from the player scoreboard element
  this.get_scoreboard_html = function() {
    // Creating the container
    j = document.createElement("div");
    j.classList.add("player");
    //j.classList.add("human")
    // Create the rank
    k = document.createElement("span");
    k.classList.add("rank");
    k.innerHTML = this.rank;
    j.appendChild(k);
    // Create the name
    k = document.createElement("span");
    k.classList.add("name");
    k.innerHTML = this.name;
    j.appendChild(k);
    // Create the points/score
    // TODO: Make the verbiage consistent - points vs. score
    k = document.createElement("span");
    k.classList.add("points");
    k.innerHTML = Math.round(this.score) + " pts";
    j.appendChild(k);
    // Create the faction
    k = document.createElement("span");
    k.classList.add("faction");
    k.innerHTML = this.members.length + " Players";
    j.appendChild(k);
    // Create the status
    k = document.createElement("span");
    k.classList.add("status");
    k.innerHTML = "Squad Leader: <a href='#'>" + this.leader.name + "</a>";
    j.appendChild(k);
    return j
  }

}
var thisgame = new Game({id: 1, logged_in_user_id: 33})
thisgame.append_on_load_info("info", function() {
  jQuery.each(thisgame.retrieved_data["info"], function(k, v) {
    thisgame[k] = v
  })
})
