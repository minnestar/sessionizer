require 'set'
require './annealer'


unless Array.method_defined?(:sample)
  class Array
    def sample
      self[rand(self.count)]
    end
  end
end


module Scheduling
  class Schedule
  
    def initialize(sessions, time_slots, max_per_slot, interests, presenters)
      @sessions, @time_slots, @max_per_slot, @interests, @presenters = sessions, time_slots, max_per_slot, interests, presenters
    
      @slots_by_session = {}
      @sessions_by_slot = {}
      unassigned = sessions.shuffle
      @time_slots.each do |slot|
        slot_sessions = unassigned.slice!(0, max_per_slot)
        slot_sessions << Unassigned.new while slot_sessions.count < max_per_slot
        slot_sessions.each { |session| @slots_by_session[session] = slot }
        @sessions_by_slot[slot] = slot_sessions
      end
    end
    
    def initialize_copy(source)
      @slots_by_session = @slots_by_session.dup
      @sessions_by_slot = Hash.new { |h,k| h[k] = [] }
      @slots_by_session.each { |session, slot| @sessions_by_slot[slot] << session }
    end
  
    def energy
      overlap_score(@interests) + overlap_score(@presenters) * 50
    end
  
    def random_neighbor
      dup.random_neighbor!
    end
    
    def random_neighbor!
      # Choose 2 or more random sessions in distinct time slots
      k = 1.0 / (@time_slots.size - 1)
      cycle_size = 1 + ((1 + k) / (rand + k)).floor
      slot_cycle = @time_slots.shuffle.slice(0, cycle_size)
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
      s = "Schedule  energy = #{self.energy}    presenter overlap = #{overlap_score(@presenters)}\n"
      @time_slots.each do |slot|
        s << "  #{slot}\n"
        @sessions_by_slot[slot].each do |session|
          s << "    #{session}\n"
        end
      end
      s
    end

  private

    class Unassigned
      def to_s
        "<< open >>"
      end
    end
    
    def overlap_score(session_sets)
      return 0 if session_sets.empty?
      
      score = 0
      slots_used = Set.new
      
      session_sets.each do |set|
        next if set.empty?
        overlaps = 0
        set.each do |session|
          unless slots_used.add? @slots_by_session[session]
            overlaps += 1
          end
        end
        slots_used.clear
        score += overlaps / set.count.to_f
      end
      
      score / session_sets.count
    end
  end
end





sched = Scheduling::Schedule.new(
  %w(soup nuts penguins walruses monkeys chickens ocelots snowboarding windsurfing bobsledding glossolalia),
  %w(9:00 10:00 11:00 12:00),
  4,
  [%w(soup nuts),
   %w(penguins walruses monkeys chickens),
   %w(snowboarding windsurfing),
   %w(glossolalia nuts monkeys),
   %w(soup nuts penguins walruses monkeys chickens ocelots snowboarding windsurfing bobsledding glossolalia),
   %w(windsurfing walruses glossolalia ocelots),
   %w(windsurfing monkeys),
   %w(windsurfing nuts penguins),
   %w(snowboarding ocelots monkeys),
   %w(nuts ocelots chickens),
   %w(snowboarding glossolalia),
   %w(chickens soup),
   %w(penguins soup),
   %w(snowboarding walruses nuts)],
  [%w(penguins snowboarding bobsledding),
   %w(penguins ocelots)])

p sched

annealer = Scheduling::Annealer.new(:max_iter => 50000, :cooling_time => 100000000)
best = annealer.anneal(sched)
puts "BEST SOLUTION:"
p best
