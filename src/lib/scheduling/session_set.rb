require 'set'

module Scheduling

  # A set of sessions which can be scored against a particular schedule.
  #
  # This can represent the set of sessions an attendee is interested in seeing,
  # or the set a presenter is presenting. Either way, we want sessions booked in
  # nonoverlapping timeslots.
  #
  class SessionSet
    def initialize(ctx, superset: nil, penalty_callback: ->(*args) { 0 })
      @ctx = ctx
      @superset = superset
      @penalty_callback = penalty_callback

      @sessions = Set.new
    end

    def add(session_id)
      @sessions << session_id
      @superset.add(session_id) if @superset
    end

    # Score if sessions are evenly distributed among all the timeslots.
    #
    def best_possible_score
      [@ctx.timeslots.size / size.to_f, 1.0].min
    end

    # Score if everything is in the same timeslot.
    #
    def worst_possible_score
      1.0 / size
    end

    def score(schedule)
      return 0 if @sessions.empty?  # prevents divide by zero below
      
      slots_used = Set.new
      overlaps = 0

      @sessions.each do |session|
        slot = schedule.slot_for(session)
        unless slots_used.add? slot
          overlaps += 1
        end
        overlaps += @penalty_callback.call(slot)
      end

      overlaps / @sessions.size.to_f
    end

    %i(size each empty?).each do |forwarded_method|
      define_method(forwarded_method) do |*args, &block|
        @sessions.send(forwarded_method, *args, &block)
      end
    end

  end
end
