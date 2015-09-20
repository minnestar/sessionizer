module Scheduling
  # ActiveModel access is slow enough that we create a stripped-down, in-memory version of the various
  # models we need to create a schedule, then run the annealer against this in-memory model.
  # This class sucks all the rooms, sessions and timeslots from the DB, and provides them during annealing.
  #
  # A Context, its Person objects, and their SessionSets do _not_ change during annealing.
  # The Schedule class contains all the state we're trying to optimize.
  #
  class Context
    attr_reader :sessions, :timeslots, :rooms

    def initialize(event)
      @sessions = event.sessions.where(timeslot: nil).pluck(:id)
      @timeslots = event.timeslots.where(schedulable: true)
      @rooms = event.rooms.where(schedulable: true)
      @people_by_id = Hash.new { |h,id| h[id] = Person.new(self, id) }

      load_sets :attending,  Attendance
      load_sets :presenting, Presentation

      report_count :attending
      report_count :presenting

      raise 'No session-presenter relationships in DB. Did you populate the presentations table?' unless people.size > 0

      event.presenter_timeslot_restrictions.each do |restriction|
        person(restriction.participant_id).
          assign_timeslot_penalty(restriction.timeslot_id, restriction.weight)
      end
    end

    def people
      @people_by_id.values
    end

  private

    def person(id)
      @people_by_id[id]
    end

    # @param [Symbol] role
    # @param [Class] either Attendance or Presentation
    def load_sets(role, association_model)
      # This brute force iteration is hardly slick, but I'm too rusty on fancy ActiveRecord querying to care just now. -PPC
      size = association_model.where(session_id: @sessions).select(:participant_id, :session_id).each do |assoc|
        person(assoc.participant_id).
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
