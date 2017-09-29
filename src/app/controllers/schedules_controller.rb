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
    cal.timezone do |t|
      t.tzid = "America/Chicago"

      t.daylight do |d|
        d.tzoffsetfrom = "-0600"
        d.tzoffsetto   = "-0500"
        d.tzname       = "CDT"
        d.dtstart      = "19700308T020000"
        d.rrule        = "FREQ=YEARLY;BYMONTH=3;BYDAY=2SU"
      end

      t.standard do |s|
        s.tzoffsetfrom = "-0500"
        s.tzoffsetto   = "-0600"
        s.tzname       = "CST"
        s.dtstart      = "19701101T020000"
        s.rrule        = "FREQ=YEARLY;BYMONTH=11;BYDAY=1SU"
      end
    end

    sessions.each do |session|
      next if session.timeslot.nil?

      cal.event do |e|
        e.summary     = session.title
        e.organizer   = Icalendar::Values::CalAddress.new('', cn: session.presenter_names.join("\\, "))
        e.description = session.summary
        e.dtstart     = session.timeslot.starts_at.to_datetime
        e.dtend       = session.timeslot.ends_at.to_datetime

        e.location    = session.room.name
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
