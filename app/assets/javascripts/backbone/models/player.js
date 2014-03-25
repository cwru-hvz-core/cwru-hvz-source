var HvZ = {};

HvZ.Player = Backbone.Model.extend({
  submitAttendanceForMission : function(missionId) {
    $.post('/attendances', {
      attendance: {
        'registration_id' : this.id,
        'mission_id' : missionId,
      }
    }).done(function(data) {
      if (data['id']) {
        this.set('attendance', data['id']);
      }
    }.bind(this));
  },
});
