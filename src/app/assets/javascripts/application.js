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
//= require typeahead.min
//= require fancybox

var Sessionizer = {};

Sessionizer.Attend = function() {
  function attendanceUrl() {
    return window.location.origin + window.location.pathname + '/attendance.json';
  }

  function sendAttendanceRequest(opts) {
    opts.beforeSend = function(xhr) {
      xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
    };
    opts.dataType = 'html';
    if(opts.hasOwnProperty('attending')) {
      opts.type = opts.attending ? 'POST' : 'DELETE';
      delete opts.attending;
    }

    $.ajax(opts);
  }

  return {
    setup: function() {
      $("button#attend").click(Sessionizer.Attend.attend);

      var $attendingToggles = $(".toggle-attendance");
      if($attendingToggles.length > 0) {
        $attendingToggles.click(Sessionizer.Attend.toggle);
        
        Sessionizer.Attend.list(function(sessionIDs) {
          $attendingToggles.each(function(index, elem) {
            sessionID = $(elem).attr('data-session-id');
            $(elem).attr('data-session-attending', sessionIDs.indexOf(sessionID) != -1);
          });
        });
      }
    },

    attend: function() {
      sendAttendanceRequest({
        url: attendanceUrl(),
        attending: true,
        success: function(data, textStatus) {
          $("div#interested-in-attending").after('<div id="flash_notice">Thanks for your interest in this session.</div>');
          $("div#interested-in-attending").slideUp();
          $("div#no-participants").fadeOut('fast');
          $("ul#participants").prepend("<li><b>You!</b></li>");
        },
        error: function(xmlhttp) {
          $("div#interested-in-attending").html(xmlhttp.responseText);
        }
      });

      return false;
    },

    toggle: function(e) {
      e.stopPropagation();
      $button = $(e.target)
      var sessionID = $button.data("session-id");
      var attending = $button.attr("data-session-attending") == "true";  // Don't let jQuery keep secret data; css needs data attr

      $button.addClass("loading");
      sendAttendanceRequest({
        url: "/sessions/" + sessionID + "/attendance.json",
        attending: !attending,
        success: function(data, textStatus) {
          $button.removeClass("loading");
          $button.attr("data-session-attending", !attending);
        },
        error: function(xmlhttp) {
          console.log("error", arguments);
          $button.removeClass("loading");
        }
      });
    },

    list: function(success) {
      sendAttendanceRequest({
        url: '/attendances',
        success: success,
        error: function(xmlhttp) {
          console.log("error", arguments);
        }
      });
    }
  };
}();

$(function() {
  $(Sessionizer.Attend.setup);
});
