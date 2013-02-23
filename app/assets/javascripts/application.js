// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs

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
                $("div#flash_message_placeholder").after('<div id="flash_notice">Thanks for your interest in this session.</div>');
                $("div#interested-in-attending").hide();
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

