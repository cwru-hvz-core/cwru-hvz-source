HvZ.AttendingPlayers = Backbone.View.extend({
  template : _.template($('#playersTemplate').html()),

  el : '#attendingPlayers',

  events : {
    'click a.player-attendance': 'deleteAttendance',
  },

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

  deleteAttendance : function(e) {
    var attendanceId = $(e.target).data('attendance');
    this.playerList.deleteAttendance(attendanceId);
    $.ajax({
      url: '/attendances/' + attendanceId,
      type: 'post',
      dataType: 'json',
      data: {"_method": "delete"},
      success: function(result) {
        console.log(result);
      }
    });
    return false;
  },

  render : function() {
    var playersInAttendance = _.filter(this.playerList.models, function(p) { return p.get('attendance') > 0; });
    var humans = _.filter(playersInAttendance, function(p) { return p.get('faction') == 0 });
    var zombies = _.filter(playersInAttendance, function(p) { return p.get('faction') == 1 });
    var deceased = _.filter(playersInAttendance, function(p) { return p.get('faction') == 2 });

    this.$el.html(this.template({ players: playersInAttendance, zombies: zombies, humans: humans, deceased: deceased }));
  },

  submitAttendance : function(e) {
    e.model.submitAttendanceForMission(this.missionId);
  }
});
