module Scheduling

  # Lightweight model for a person, who has a (possibly empty) set of sessions
  # they'd like to attend, and another at which they're presenting.
  #
  class Person
    attr_reader :id, :attending, :presenting

    def initialize(ctx, id)
      @id = id
      @attending  = SessionSet.new(ctx)
      @presenting = SessionSet.new(ctx,
        superset: @attending,            # Presenters don't necessarily upvote their own sessions, but they do attend!
        penalty_callback: ->(slot_id) do    # Presenters may have other scheduling constraints beside double booking
          @timeslot_penalties[slot_id]
        end)
      @timeslot_penalties = Hash.new(0)
    end

    # Value greater than 0 indicates desire not to present in given slot; 1 means "impossible."
    #
    def assign_timeslot_penalty(slot_id, penalty)
      @timeslot_penalties[slot_id] = penalty
    end
  end
end
