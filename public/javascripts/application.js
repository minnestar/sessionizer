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
              beforeSend: function(xhr) {
                xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
              },
              type: 'POST',
              dataType: 'html',
              success: function(data, textStatus) {
                $("div#interested-in-attending").html("Thanks for your interest in this session.");
                $("div#no-participants").hide();
                $("ul#participants").prepend(data);
              },
              error: function(xmlhttp) {
                $("div#interested-in-attending").html(xmlhttp.responseText);
              }
             });

      return false;
    }
  };
}();

$(function() {
    $(Sessionizer.Attend.setup);
  });
