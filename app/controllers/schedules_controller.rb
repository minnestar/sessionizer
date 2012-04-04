class SchedulesController < ApplicationController
  def index
    @event = Event.current_event :include => { :timeslots => { :sessions => [:room, :presenters] } }
  end

  def ical
    event = Event.current_event
    
    sessions = event.sessions.all(:include => [:room, :timeslot])
    calendar = RiCal.Calendar do |cal|
      sessions.each do |session|
        cal.event do |entry|
          entry.summary = session.title
          entry.dtstart = session.timeslot.starts_at
          entry.dtend = session.timeslot.ends_at
          entry.location = session.room.name
        end
      end
    end

    render :text => calendar.to_s, :content_type => 'text/calendar'
  end

end
