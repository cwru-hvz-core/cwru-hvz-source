HvZ.AttendingPlayers = Backbone.View.extend({
  template : _.template("<% _.each(players, function(p) { %> <%= p.get('name') %> <br /> <% }); %>"),

  el : '#attendingPlayers',

  initialize : function(options) {
    this.playerList = new HvZ.PlayerList(options.players);
    this.missionId = options.missionId;

    this.autoComplete = new HvZ.PlayerAutocomplete({
      playerList : this.playerList,
    });

    this.listenTo(this.playerList, 'change', this.render);
    this.listenTo(this.autoComplete, 'autocomplete:selected', this.submitAttendance);

    this.render();
  },

  render : function() {
    var playersInAttendance = _.filter(this.playerList.models, function(p) { return p.get('attending'); });

    this.$el.html(this.template({ players : playersInAttendance }));
  },

  submitAttendance : function(e) {
    e.model.submitAttendanceForMission(this.missionId);
  }
});
