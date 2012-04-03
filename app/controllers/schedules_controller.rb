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
    calendar = RiCal.Calendar do |cal|
      sessions.each do |session|
        next if session.timeslot.nil?
        
        cal.event do |entry|
          entry.summary = session.title
          entry.description = session.presenter_names.to_sentence
          entry.dtstart = session.timeslot.starts_at
          entry.dtend = session.timeslot.ends_at
          entry.location = session.room.name
        end
      end
    end

    render :text => calendar.to_s, :content_type => 'text/calendar'
  end

end
