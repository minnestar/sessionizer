module Scheduling

  # A set of sessions which can be scored against a particular schedule.
  #
  # This can represent either the set of sessions an attendee is interested in seeing,
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

    # The score if sessions are evenly distributed among all available timeslots.
    #
    def best_possible_score
      return 1 if empty?

      @best_possible_score ||= begin
        slot_count = @ctx.timeslots.size
        even_split_floor = size / slot_count
        big_slots = size % slot_count
        small_slots = slot_count - big_slots
        [
          small_slots * slot_value(even_split_floor)    + 
            big_slots * slot_value(even_split_floor + 1),
          1.0
        ].min
      end
    end

    # The score if everything is in the same timeslot.
    #
    def worst_possible_score
      return 1 if empty?
      1.0 / size
    end

    # The average score of a randomly assigned schedule. This is a good baseline
    # for what the scheduler is trying to improve on — more so than worst_possible_score,
    # which tends to be far worse than any actual schedule would generate.
    #
    def random_schedule_score
      return 1 if empty?

      slot_count = @ctx.timeslots.size

      @@random_schedule_scores ||= {}
      @@random_schedule_scores[[slot_count, size]] ||= begin
        # Someone more knowledgeable than me can probably find
        # a closed form for this. But brute force works!
        trials = 1000
        total = 0
        trials.times do
          counts = [0] * slot_count
          size.times { counts[rand(slot_count)] += 1 }
          total += counts.sum { |c| slot_value(c) }
        end
        total / trials.to_f
      end
    end

    def score(schedule)
      return 1 if empty?
      
      slot_session_count = Hash.new(0)
      penalty = 0

      @sessions.each do |session|
        slot = schedule.slot_id_for(session)
        next unless slot  # happens when session is manually_scheduled & not in a timeslot
        slot_session_count[slot] += 1
        penalty += @penalty_callback.call(slot)
      end

      satisfaction = slot_session_count.values.sum do |k|
        slot_value(k)
      end

      satisfaction - penalty / size.to_f
    end

    def size
      @sessions.size
    end

    def empty?
      @sessions.empty?
    end

  private

    # Assume each attendee has some ranking of all the sessions in which they expressed interest.
    # (Not an unreasonable assumption.) Further assume that the attendee values their sessions of interest
    # linearly: least interested=1,2,3...N=most interested. (That's more of a stretch, but likely bears
    # some resemblance to reality.)
    #
    # In each timeslot, assume the attendee will choose the session they're most interested in. We don't
    # know attendee's actual ranking, so assume sessions of interest are distributed randomly in the schedule.
    # The expected maximum of a slot in which there are k sessions is v_slot = k(N+1)/(k+1). The total
    # value of all sessions is v_total = N(N+1)/2. The expected fraction of total value in one slot is
    # thus v_slot / v_total = 2k/(N(k+1)). Sum that over all slots to get the attendee's overall satisfaction.
    #
    # A similar logic applies to presenters avoiding double-booking.
    #
    # (The old scheduling algorithm didn't take into account how deep the overlap ran within a given slot,
    # essentially set v_slot = {1/N if any sessions of interest, 0 otherwise}.)
    #
    def slot_value(k)
      2 * k / (size.to_f * (k + 1))
    end

  end
end
