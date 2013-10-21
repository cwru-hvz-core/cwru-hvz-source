HvZ.PlayerAutocomplete = Backbone.View.extend({
  template : _.template("<% _.each(results, function(name, i) { %> <li data-position='<%= i %>' <% if (i === selectedIndex) { %> class='selected' <% } %>><%= name %></li> <% }); %>"),

  el: '#playerList',

  events : {
    'keyup .autocomplete-search-field': 'performSearch',
    'keydown .autocomplete-search-field': 'updateSelectionViaKeyboard',
    'mousemove .autocomplete-search-results': 'updateSelectionViaMouse',
    'click .autocomplete-search-results': 'clickDropdown',
  },

  initialize : function(options) {
    this.selectedIndex = 0;

    this.$el.html("<div class='autocomplete-container'><input type='text' class='autocomplete-search-field' /><ul class='autocomplete-search-results'></ul></div>");
    this.$searchField = this.$('.autocomplete-search-field');
    this.lastQuery = this.$searchField.val();
    this.foundPlayers = [];

    this.playerList = options.playerList;
  },

  clickDropdown : function(e) {
    var $clicked = $(e.target);
    this.selectedIndex = parseInt($clicked.data('position'));

    this.submitAttendance();
  },

  performSearch : function() {
    var q = this.getQuery();

    if (q !== this.lastQuery) {
      this.foundPlayers = this.playerList.search(q);
      this.selectedIndex = 0;
      this.lastQuery = q;

      this.render();
    }
  },

  render : function(e) {
    var playerNames = _.map(this.foundPlayers, function(p) { return p.get('name'); });
    this.$('.autocomplete-search-results').html(this.template({ results : playerNames, selectedIndex : this.selectedIndex }));
  },

  clear : function() {
    this.foundPlayers = [];
    this.$searchField.val('');
    this.render();
  },

  updateSelectionViaMouse : function(e) {
    var $hover = $(e.target);
    this.selectedIndex = parseInt($hover.data('position'));

    this.render();
  },

  updateSelectionViaKeyboard : function(e) {
    if (e.keyCode === 38) { // up
      this.selectedIndex = this.selectedIndex > 0 ? this.selectedIndex - 1 : 0;
    } else if (e.keyCode === 40) { // down
      this.selectedIndex = this.selectedIndex < this.foundPlayers.length ? this.selectedIndex + 1 : this.selectedIndex;
    } else if (e.keyCode == 13) { // enter
      this.submitAttendance();
    }

    this.render();
  },

  submitAttendance : function() {
    var selectedModel = this.foundPlayers[this.selectedIndex];
    selectedModel.submitAttendanceForMission(this.options.missionId);

    this.clear();
  },

  getQuery : function() {
    return this.$searchField.val();
  }
});
