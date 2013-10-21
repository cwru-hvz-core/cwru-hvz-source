HvZ.PlayerList = Backbone.Collection.extend({
  model: HvZ.Player,
  search : function(q) {
    if (q === '' || q === undefined || q.length <= 1) {
      return [];    // prevent visual clutter
    }

    return _.sortBy(_.filter(this.models, function(player) {
      return _.some(player.get('name').toLowerCase().split(' '), function(chunk) {
        return chunk.indexOf(this.q.toLowerCase()) == 0;
      }, { q : q });
    }, { q : q }), function(p) {
      return p.get('name').toLowerCase().indexOf(this.q.toLowerCase());
    }, { q : q });
  },
});
