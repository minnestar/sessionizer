var Sessionizer = {};

Sessionizer.Attend = function() {
  function attendanceUrl() {
    return window.location.href + '/attendance.json';
  }

  return {
    setup: function() {
      $("a#attend").click(Sessionizer.Attend.attend);
    },

    attend: function() {
      $.ajax({url: attendanceUrl(),
              type: 'POST',
              dataType: 'html',
              success: function(data, textStatus) {
                $("div#interested-in-attending").html("Thanks for your interest in this session.");
                $("div#no-participants").hide();
                $("ul#participants").prepend(data);
              }
             });

      return false;
    }
  };
}();

$(function() {
    $(Sessionizer.Attend.setup);
  });
