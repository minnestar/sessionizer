class SchedulesController < ApplicationController
  def index
    @current_event = Event.current_event
    
    @rooms = @current_event.rooms
    @timeslots = @current_event.timeslots

    @sessions = { }
    sessions_by_timeslot = @current_event.sessions.all.group_by(&:timeslot)
    @timeslots.each do |timeslot|
      @sessions[timeslot] = { }
      @rooms.each do |room|
        @sessions[timeslot][room] = sessions_by_timeslot[timeslot].find { |session| session.room == room }
      end
    end
  end

  def ical
    event = Event.current_event
    
    sessions = event.sessions.all(:include => [:room, :timeslot])


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
        description session.presenter_names.to_sentence
        dtstart     session.timeslot.starts_at
        dtend       session.timeslot.ends_at
        location    session.room.name
      end
    end

    render :text => calendar.to_s, :content_type => 'text/calendar'
  end

end
