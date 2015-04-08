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
      
      # Create a random schedule to start
      
      unassigned = ctx.sessions.shuffle
      room_count = ctx.rooms.size
      ctx.timeslots.each do |slot|
        slot_sessions = unassigned.slice!(0, room_count)
        slot_sessions << Unassigned.new while slot_sessions.size < room_count
        slot_sessions.each { |session| reschedule(session, slot)  }
      end
      unless unassigned.empty?
        raise "Not enough room / slot combinations! There are #{ctx.sessions.size} sessions, but only #{ctx.timeslots.size} times slots * #{room_count} rooms = #{ctx.timeslots.size * room_count} combinations."
      end
    end
    
    def initialize_copy(source)  # deep copy; called by dup
      @slots_by_session = @slots_by_session.dup
      @sessions_by_slot = Hash.new { |h,k| h[k] = [] }
      @slots_by_session.each { |session, slot| @sessions_by_slot[slot] << session }
    end

    def slot_for(session)
      @slots_by_session[session]
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
       attendance_energy + presenter_energy
    end
    
    def attendance_energy
      1 - score(:attending)
    end
    
    def presenter_energy
      (1 - score(:presenting)) * ctx.people.count   # Presenter double-bookings trump attendance preferences
    end

    # Gives lower & upper bounds on the possible range of attendance_energy
    def attendance_score_bounds
      best_score  = ctx.people.sum { |p| p.attending.best_possible_score }
      worst_score = ctx.people.sum { |p| p.attending.worst_possible_score }
      count = ctx.people.size
      (worst_score / count) .. (best_score / count)
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
        reschedule @sessions_by_slot[old_slot].sample, new_slot
      end
      
      self
    end

  private

    def reschedule(session, new_slot)
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
          sessions = Session.find(session_ids.reject { |s| Unassigned === s }).sort_by { |s| -s.attendances.size }
          sessions.zip(rooms_by_capacity) do |session, room|
            puts "    #{session.categories.map(&:name).inspect} #{session.title} (#{session.attendances.size}) in #{room.name} (#{room.capacity})"
            session.timeslot = slot
            session.room = room
            session.save!
          end
        end
      end
    end
    
    def inspect
      s = "Schedule"
      s << " | average participant can attend #{format_percent score(:attending)} of their sessions of interest"
      s << " | presenter score = #{format_percent score(:presenting)} (we want 100)\n"
      ctx.timeslots.each do |slot|
        s << "  #{slot}: #{@sessions_by_slot[slot].join(' ')}\n"
      end
      s
    end

    def inspect_bounds
      possible_range = self.attendance_score_bounds
      s = "Extreme bounds on possible result: the average participant can possibly attend...\n"
      s << "    at worst #{'%03.3f' % ((possible_range.begin) * 100)}%\n"
      s << "    at best  #{'%03.3f' % ((possible_range.end  ) * 100)}%\n"
      s << "...of their sessions of interest."
      s << " (Note that these are just limits on what is possible."
      s << " Neither bounds is actually likely to be achievable.)"
    end
    
  private

    def format_percent(x)
      "#{'%1.3f' % (x * 100)}%"
    end

  end
end

