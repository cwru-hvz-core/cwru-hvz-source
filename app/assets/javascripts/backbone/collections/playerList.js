HvZ.PlayerList = Backbone.Collection.extend({
  model: HvZ.Player,
  search : function(q) {
    if (q === '' || q === undefined || q.length < 2) {
      return [];    // prevent visual clutter
    }

    return _.filter(this.models, function(player) {
      // todo: sort by edit distance?
      return player.get('name').toLowerCase().indexOf(this.q.toLowerCase()) >= 0;
    }, { q : q });
  },
});
