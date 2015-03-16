require 'set'
require 'pp'


unless Array.method_defined?(:sample)
  class Array
    def sample
      self[rand(self.count)]
    end
  end
end


# Represents a particular schedule (i.e. assignment of sessions to rooms) for the purpose of annealing.
# Scores the schedule and returns nearby variations.
#
module Scheduling
  class Schedule
    def initialize(event)
      @ctx = Scheduling::Context.new(event)
      
      @slots_by_session = {}                            # map from session to timeslot
      @sessions_by_slot = Hash.new { |h,k| h[k] = [] }  # map from timeslot to array of sessions
      
      # Create a random schedule to start
      
      unassigned = ctx.sessions.shuffle
      room_count = ctx.rooms.count
      ctx.timeslots.each do |slot|
        slot_sessions = unassigned.slice!(0, room_count)
        slot_sessions << Unassigned.new while slot_sessions.count < room_count
        slot_sessions.each { |session| reschedule(session, slot)  }
      end
      unless unassigned.empty?
        raise "Not enough room / slot combinations! There are #{ctx.sessions.count} sessions, but only #{ctx.timeslots.count} times slots * #{room_count} rooms = #{ctx.timeslots.count * room_count} combinations."
      end
    end
    
    def initialize_copy(source)  # deep copy; called by dup
      @slots_by_session = @slots_by_session.dup
      @sessions_by_slot = Hash.new { |h,k| h[k] = [] }
      @slots_by_session.each { |session, slot| @sessions_by_slot[slot] << session }
    end
  
    # This is the metric we're trying to minimize. It's called "energy" in simulated annealing by analogy to the
    # real-life physical process of annealing, in which a cooling material minimizes the energy of its chemical bonds.
    def energy
       attendance_energy + presenter_energy
    end
    
    def attendance_energy
      overlap_score :attendees
    end
    
    def presenter_energy
      overlap_score(:presenters) * ctx.attendee_count
    end
  
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
        new_slot = slot_cycle[(i+1) % slot_cycle.count]
        reschedule @sessions_by_slot[old_slot].sample, new_slot
      end
      
      self
    end
    
    def assign_rooms_and_save!
      Session.transaction do
        rooms_by_capacity = ctx.rooms.sort_by { |r| -r.capacity }
        @sessions_by_slot.sort_by { |k,v| k.starts_at }.each do |slot_id, session_ids|
          slot = Timeslot.find(slot_id)
          puts slot
          sessions = Session.find(session_ids.reject { |s| Unassigned === s }).sort_by { |s| -s.attendances.count }
          sessions.zip(rooms_by_capacity) do |session, room|
            puts "    #{session.categories.map(&:name).inspect} #{session.title} (#{session.attendances.count}) in #{room.name} (#{room.capacity})"
            session.timeslot = slot
            session.room = room
            session.save!
          end
        end
      end
    end
    
    def inspect
      s = "Schedule"
      s << " | average participant can attend #{'%1.3f' % ((1 - attendance_energy) * 100)}% of their sessions of interest"
      s << " | presenter exclusion score = #{presenter_energy} (we want zero)\n"
      ctx.timeslots.each do |slot|
        s << "  #{slot}: #{@sessions_by_slot[slot].join(' ')}\n"
      end
      s
    end
    
  private

    attr_reader :ctx
    
    def overlap_score(role)
      
      score = 0.0
      slots_used = Set.new
      
      count = ctx.each_session_set(role) do |participant, session_set, penalty_callback|
        next if session_set.empty?  # prevents divide by zero
        
        slots_used.clear
        overlaps = 0
        session_set.each do |session|
          slot = @slots_by_session[session]
          unless slots_used.add? slot
            overlaps += 1
          end
          overlaps += penalty_callback.call(slot)
        end
        
        score += overlaps / session_set.count.to_f
      end
      
      if count == 0
        0
      else
        score / count
      end
    end

    def reschedule(session, new_slot)
      old_slot = @slots_by_session[session]
      @sessions_by_slot[old_slot].delete(session) if old_slot
      
      @slots_by_session[session] = new_slot
      @sessions_by_slot[new_slot] << session if new_slot
    end
    
    class Unassigned
      def to_s
        "<< open >>"
      end
    end

  end
end

