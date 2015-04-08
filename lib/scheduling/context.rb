# ActiveModel access is slow enough that we create a stripped-down, in-memory version of the various
# models we need to create a schedule, then run the annealer against this in-memory model.
#
# This class sucks all the rooms, sessions and timeslots from the DB, and provides them during annealing.
#
# A Scheduling object does _not_ change during annealing. The Schedule class contains all the state
# information that we're trying to optimize.
#
module Scheduling
  class Context
    
    attr_reader :sessions, :timeslots, :rooms
  
    def initialize(event)
      @sessions = event.session_ids
      @timeslots = event.timeslots
      @rooms = event.rooms
      @people_by_id = Hash.new { |h,id| h[id] = Person.new(self, id) }

      load_sets :attending,  Attendance
      load_sets :presenting, Presentation

      report_count :attending
      report_count :presenting
      
      raise 'No session-presenter relationships in DB. Did you populate the presentations table?' unless people.size > 0
      
      # Certain presenters can't present at certain times
      @timeslot_restrictions = {}
      event.presenter_timeslot_restrictions.each do |ptsr|
        @timeslot_restrictions[[ptsr.participant_id, ptsr.timeslot_id]] = ptsr.weight
      end
    end

    def people
      @people_by_id.values
    end
    
    def attendee_count
      people.count
    end
    
    # Iterates over participants in the given role, which may be either :attending or :presenting.
    #
    # The given block receives three parameters:
    #  - the person,
    #  - the SessionsSet in which the person has the given role (and thus doesn't want in the same slot), and
    #  - a callback which gives an additional penalty for a given slot.
    #
    # Returns the number of participants yielded.
    def each_session_set(role, &block)
      slot_penalties = case role
        when :attending
          {}
        when :presenting
          @timeslot_restrictions
        else
          raise "Unknown role #{role.inspect}"
      end
      people.each do |person|
        yield person, person.send(role), lambda { |slot| slot_penalties[[person.id, slot.id]] || 0 }
      end.count
    end
  
  private
    
    def load_sets(role, association_model)
      # This brute force iteration is hardly slick, but I'm too rusty on fancy ActiveRecord querying to care just now. -PPC
      size = association_model.where(session_id: @sessions).select(:participant_id, :session_id).each do |assoc|
        @people_by_id[assoc.participant_id].
          send(role).
          add(assoc.session_id)
      end.size
    end

    def report_count(role)
      assoc_count = people.map { |p| p.send(role).size }.sum
      person_count = people.count { |p| p.send(role).size > 0 }
      puts "#{assoc_count} #{role.to_s.humanize.downcase} relationships" +
           " (#{person_count} people, avg #{"%1.1f" % (assoc_count / person_count.to_f)} each)"
    end   
  end
end
