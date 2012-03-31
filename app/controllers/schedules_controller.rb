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
end
