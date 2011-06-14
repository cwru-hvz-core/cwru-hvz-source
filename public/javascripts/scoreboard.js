$(function() {
  $.ajax({
    url: "http://tomdooner.com:3000/api/game/1?type=players",
    dataType: "text",
    success: function(data, textStatus, jqXHR) {
      $("#game_content").html(data);
    }
  })
});
