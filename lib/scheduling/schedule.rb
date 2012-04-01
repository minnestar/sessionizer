require 'set'
require 'pp'


unless Array.method_defined?(:sample)
  class Array
    def sample
      self[rand(self.count)]
    end
  end
end


module Scheduling
  class Schedule
    
    def self.build_sets(sessions, association_class)
      # This brute force iteration is hardly slick, but I'm too rusty on fancy querying in Rails 2.3 to care just now. -PPC
      session_set = Hash.new { |h,k| h[k] = [] }
      association_class.find(:all, :conditions => { :session_id => sessions }, :select => 'participant_id, session_id').each do |assoc|
        session_set[assoc.participant_id] << assoc.session_id
      end
      puts "#{session_set.count} #{association_class.name.pluralize.humanize.downcase}"
      session_set
    end
  
    def initialize(event)
      @sessions = event.session_ids
      @timeslots = event.timeslots
      @max_per_slot = event.rooms.count
      
      @attendance_sets = Schedule.build_sets @sessions, Attendance    # These are both maps from participant_id to array of session_ids
      @presenter_sets  = Schedule.build_sets @sessions, Presentation
      
      raise 'No session-presenter relationships in DB. Did you populate the presentations table?' unless @presenter_sets.count > 0
      
      # Presenters also attend their own sessions, which isn't necessarily reflected in the attendances:
      @presenter_sets.each do |person, sessions|
        @attendance_sets[person] += sessions
        @attendance_sets[person].uniq!
      end
      
      @timeslot_restrictions = {}
      event.presenter_timeslot_restrictions.each do |ptsr|
        @timeslot_restrictions[[ptsr.participant_id, ptsr.timeslot_id]] = ptsr.weight
      end
      p @timeslot_restrictions
      
      # Create a random schedule to start
      
      @slots_by_session = {}  # map from session_id to timeslot
      @sessions_by_slot = {}  # map from timeslot to array of session_ids
      unassigned = @sessions.shuffle
      @timeslots.each do |slot|
        slot_sessions = unassigned.slice!(0, @max_per_slot)
        slot_sessions << Unassigned.new while slot_sessions.count < @max_per_slot
        slot_sessions.each { |session| @slots_by_session[session] = slot }
        @sessions_by_slot[slot] = slot_sessions
      end
      unless unassigned.empty?
        raise "Not enough room / slot combinations! There are #{@sessions.count} sessions, but only #{@timeslots.count} times slots * #{@max_per_slot} rooms = #{@timeslots.count * @max_per_slot} combinations."
      end
    end
    
    def initialize_copy(source)
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
      overlap_score(@attendance_sets)
    end
    
    def presenter_energy
      overlap_score(@presenter_sets, @timeslot_restrictions) * @attendance_sets.count
    end
  
    def random_neighbor
      dup.random_neighbor!
    end
    
    def random_neighbor!
      # Choose 2 or more random sessions in distinct time slots
      k = 1.0 / (@timeslots.size - 1)
      cycle_size = 1 + ((1 + k) / (rand + k)).floor
      slot_cycle = @timeslots.shuffle.slice(0, cycle_size)
      session_cycle = slot_cycle.map { |slot| @sessions_by_slot[slot].sample }
      
      # Rotate their assignments
      session_cycle.each_with_index do |session, i|
        old_slot, new_slot = slot_cycle[i], slot_cycle[(i+1) % slot_cycle.count]
        @slots_by_session[session] = new_slot
        @sessions_by_slot[old_slot].delete session
        @sessions_by_slot[new_slot] << session
      end
      
      self
    end
    
    def inspect
      s = "Schedule"
      s << " | average participant can attend #{'%1.3f' % ((1 - attendance_energy) * 100)}% of their sessions of interest"
      s << " | presenter exclusion score = #{presenter_energy} (we want zero)\n"
      @timeslots.each do |slot|
        s << "  #{slot}: #{@sessions_by_slot[slot].join(' ')}\n"
      end
      s
    end
    
    def assign_rooms_and_save!
      Session.transaction do
        rooms_by_capacity = Room.find :all, :order => 'capacity desc'
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

  private

    class Unassigned
      def to_s
        "<< open >>"
      end
    end
    
    def overlap_score(session_sets, slot_penalties = {})
      return 0 if session_sets.empty?
      
      score = 0
      slots_used = Set.new
      
      session_sets.each do |participant_id, set|
        next if set.empty?
        overlaps = 0
        set.each do |session|
          slot = @slots_by_session[session]
          unless slots_used.add? slot
            overlaps += 1
          end
          overlaps += slot_penalties[[participant_id, slot.id]] || 0
        end
        slots_used.clear
        score += overlaps / set.count.to_f
      end
      
      score / session_sets.count
    end
  end
end

