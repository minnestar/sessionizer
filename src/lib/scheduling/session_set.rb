require 'set'

module Scheduling

  # A set of sessions which can be scored against a particular schedule.
  #
  # This can represent the set of sessions an attendee is interested in seeing,
  # or the set a presenter is presenting. Either way, we want sessions booked in
  # nonoverlapping timeslots.
  #
  class SessionSet
    def initialize(ctx, superset: nil)
      @ctx = ctx
      @superset = superset

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
      raise 'niy'
    end

    %i(size each empty?).each do |forwarded_method|
      define_method(forwarded_method) do |*args, &block|
        @sessions.send(forwarded_method, *args, &block)
      end
    end

  end
end
