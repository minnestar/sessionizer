class SchedulesController < ApplicationController
  def index
    unless Settings.show_schedule? || params[:force]
      redirect_to home_page_path
      return
    end
    @event = Event.current_event
    render layout: 'schedule'
  end

  def ical
    event = Event.current_event

    sessions = event.sessions.includes([:room, :timeslot])


    cal = Icalendar::Calendar.new

    # Set up timezone
    cal.timezone do
      timezone_id             "America/Chicago"

      daylight do
        timezone_offset_from  "-0600"
        timezone_offset_to    "-0500"
        timezone_name         "CDT"
        dtstart               "19700308T020000"
        add_recurrence_rule   "FREQ=YEARLY;BYMONTH=3;BYDAY=2SU"
      end

      standard do
        timezone_offset_from  "-0500"
        timezone_offset_to    "-0600"
        timezone_name         "CST"
        dtstart               "19701101T020000"
        add_recurrence_rule   "FREQ=YEARLY;BYMONTH=11;BYDAY=1SU"
      end
    end

    sessions.each do |session|
      next if session.timeslot.nil?

      cal.event do
        summary session.title
        organizer   "", :CN => session.presenter_names.join("\\, ")
        description session.summary
        dtstart     session.timeslot.starts_at.to_datetime
        dtend       session.timeslot.ends_at.to_datetime

        location    session.room.name
      end
    end

    render plain: cal.to_ical, :content_type => 'text/calendar'
  end

  def event_timeslots
    @event_timeslots ||= load_event.timeslots
  end
  helper_method :event_timeslots

  private

  def load_event
    event = Event.includes(timeslots: { sessions: [:room, :presenters] }).find(Event.current_event.id)

    # Preload vote counts in order to sort sessions by popularity
    Session.preload_attendance_counts(
      event.timeslots.map(&:sessions).flatten)

    event
  end

end
