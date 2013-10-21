HvZ.AttendingPlayers = Backbone.View.extend({
  template : _.template("<% _.each(players, function(p) { %> <%= p.get('name') %> <br /> <% }); %>"),

  el : '#attendingPlayers',

  initialize : function(options) {
    this.playerList = options.playerList;

    this.listenTo(this.playerList, 'change', this.render);

    this.render();
  },

  render : function() {
    var playersInAttendance = _.filter(this.playerList.models, function(p) { return p.get('attending'); });

    this.$el.html(this.template({ players : playersInAttendance }));
  }
});
