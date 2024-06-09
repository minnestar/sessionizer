class SchedulesController < ApplicationController

  before_action :authenticate_participant, if: -> { params[:preview] }

  def index
    unless schedule_visible?
      redirect_to home_page_path
      return
    end
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
    @event_timeslots ||= begin
      # Timeslots only get touched if schedule isn't cached.
      # Do all the expensive preloading here.
      timeslots = event.timeslots.includes(sessions: [:room, :presenters])

      # Preload vote counts in order to sort sessions by popularity
      Session.preload_attendance_counts(
        timeslots.map(&:sessions).flatten)

      timeslots
    end
  end
  helper_method :event_timeslots

  def header_timeslots
    @header_timeslots ||= if event.multiday?
      @event.first_timeslots_of_day
    else
      event_timeslots.where(schedulable: true)
    end
  end
  helper_method :header_timeslots

  def event
    @event ||= event_from_params
  end
  helper_method :event

  # Is the schedule live and available to the general public?
  def schedule_public?
    event && (
      !event.current? ||        # All past schedules are public
      Settings.show_schedule?)  # Current event schedule has explicit go-live flag
  end
  helper_method :schedule_public?

  # Should we honor this request to show the schedule?
  def schedule_visible?
     schedule_public? || params[:preview]
  end

end
