require 'pp'


module Scheduling
  # Represents a particular schedule (i.e. assignment of sessions to rooms) for the purpose of annealing.
  # Scores the schedule and returns nearby variations.
  #
  class Schedule
    def initialize(event)
      @ctx = Scheduling::Context.new(event)

      @slots_by_session = {}                            # map from session to timeslot
      @sessions_by_slot = Hash.new { |h,k| h[k] = [] }  # map from timeslot to array of sessions

      fill_schedule!(
        event.sessions
          .where(manually_scheduled: false)
          .includes(:timeslot)
          .to_a)
    end

    def initialize_copy(source)  # deep copy; called by dup
      @slots_by_session = @slots_by_session.dup
      @sessions_by_slot = Hash.new { |h,k| h[k] = [] }
      @slots_by_session.each { |session, slot| @sessions_by_slot[slot] << session }
    end

    def slot_id_for(session_id)
      @slots_by_session[session_id].id
    end

  private

    attr_reader :ctx

    class Unassigned  # placeholder for empty room
      def to_s
        "<< open >>"
      end
    end

  public

    # ------------ Scoring ------------

    # This is the metric we're trying to minimize. It's called "energy" in simulated annealing by analogy to the
    # real-life physical process of annealing, in which a cooling material minimizes the energy of its chemical bonds.
    #
    def energy
       (1 - attendance_score) +
       (1 - presenter_score) * ctx.people.size  # Multiplier b/c presenter double-bookings trump attendance prefs
    end

    # Average attendee satisfaction with the schedule, measured as the estimated fraction of the total value
    # of all their desired sessions that this schedule will give them. (1 = perfect schedule for everyone;
    # 0 = no attendees can attend any desired sessions at all.)
    #
    def attendance_score
      score(:attending)
    end

    # Average ability of presenter to present all the sessions they signed up for. For an optimized schedule,
    # this should always be 1 unless a presenter created an inherent conflict (e.g. signing up to present more
    # sessions than there are timeslots.)
    #
    def presenter_score
      score(:presenting)
    end

    # Gives bounds on the possible range of attendance_score. Returns [best, random, worst] scores.
    def attendance_score_metrics
      count = ctx.people.size.to_f
      %i(
        worst_possible_score
        random_schedule_score
        best_possible_score
      ).map do |metric|
        ctx.people.sum { |p| p.attending.send(metric) } / count
      end
    end

  private

    def score(role)
      count = ctx.people.size
      score = ctx.people.sum do |person|
        person.send(role).score(self)
      end

      if count == 0
        1
      else
        score / count
      end
    end

  public

    # ------------ State space traversal ------------

    # Fill the schedule, using existing timeslots if any are present, assigning the remaining sessions
    # randomly, then adding Unassigned placeholders to openings in the schedule.
    #
    def fill_schedule!(sessions)
      sessions.each do |session|
        schedule(session.id, session.timeslot) if session.timeslot
      end

      unassigned = sessions.reject(&:timeslot)
      room_count = ctx.rooms.size
      ctx.timeslots.each do |slot|
        opening_count = room_count - @sessions_by_slot[slot].size
        slot_sessions = (unassigned.slice!(0, opening_count) || []).map(&:id)
        slot_sessions << Unassigned.new while slot_sessions.size < opening_count
        slot_sessions.each { |session| schedule(session, slot)  }
      end
      unless unassigned.empty?
        raise "Not enough room / slot combinations! There are #{sessions.size} sessions, but only #{ctx.timeslots.size} times slots * #{room_count} rooms = #{ctx.timeslots.size * room_count} combinations."
      end
    end

    # Return a similar but slightly different schedule. Used by the annealing algorithm to explore
    # the scheduling space.
    #
    def random_neighbor
      dup.random_neighbor!
    end

    def random_neighbor!
      # Choose 2 or more random sessions in distinct time slots
      k = 1.0 / (ctx.timeslots.size - 1)
      cycle_size = 1 + ((1 + k) / (rand + k)).floor
      slot_cycle = ctx.timeslots.shuffle.slice(0, cycle_size)

      # Rotate their assignments
      slot_cycle.each_with_index do |old_slot, i|
        new_slot = slot_cycle[(i+1) % slot_cycle.size]
        schedule @sessions_by_slot[old_slot].sample, new_slot
      end

      self
    end

  private

    def schedule(session, new_slot)
      old_slot = @slots_by_session[session]
      @sessions_by_slot[old_slot].delete(session) if old_slot

      @slots_by_session[session] = new_slot
      @sessions_by_slot[new_slot] << session if new_slot
    end

  public

    # ------------ Managing results ------------

    def assign_rooms_and_save!
      Session.transaction do
        rooms_by_capacity = ctx.rooms.sort_by { |r| -r.capacity }
        @sessions_by_slot.sort_by { |k,v| k.starts_at }.each do |slot_id, session_ids|
          slot = Timeslot.find(slot_id)
          puts slot
          sessions = Session.find(session_ids.reject { |s| Unassigned === s }).sort_by { |s| -s.estimated_interest }
          sessions.zip(rooms_by_capacity) do |session, room|
            puts "    #{session.id} #{session.title}" +
                 " (#{session.attendances.count} vote(s) / #{'%1.1f' % session.estimated_interest} interest)" +
                 " in #{room.name} (#{room.capacity})"
            session.timeslot = slot
            session.room = room
            session.save!
          end
        end
      end
    end

    def inspect
      worst_score, random_score, best_score = self.attendance_score_metrics
      attendance_score_scaled = (attendance_score - random_score) / (best_score - random_score)

      s = "Schedule\n"
      s << "| quality vs. random = #{format_percent attendance_score_scaled} (0% is no better than random; 100% is unachievable; > 50% is good)\n"
      s << "| absolute satisfaction = #{format_percent attendance_score} of impossibly perfect schedule\n"
      s << "| presenter score = #{format_percent presenter_score} (if < 100 then speakers are double-booked)\n"
      ctx.timeslots.each do |slot|
        s << "  #{slot}: #{@sessions_by_slot[slot].join(' ')}\n"
      end
      s
    end

    def inspect_bounds
      worst_score, random_score, best_score = self.attendance_score_metrics
      s =  "If we could give everyone a different schedule optimized just for them,\n"
      s << "the schedule quality could be...\n"
      s << "\n"
      s << "    at worst #{'%03.3f' % ((worst_score) * 100)}%\n"
      s << "     at best #{'%03.3f' % ((best_score ) * 100)}%\n"
      s << "\n"
      s << "Note that these are outer limits on what is possible.\n"
      s << "Neither the best nor the worst score is likely to be achievable.\n"
      s << "\n"
      s << "If we pick a schedule at random, its score will be about\n"
      s << "\n"
      s << "             #{'%03.3f' % ((random_score) * 100)}%\n"
      s << "\n"
      s << "...and that's what we're trying to improve on.\n"
    end

  private

    def format_percent(x)
      "#{'%1.3f' % (x * 100)}%"
    end

  end
end

