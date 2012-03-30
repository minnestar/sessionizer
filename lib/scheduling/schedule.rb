require 'set'


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
      by_participant = Hash.new { |h,k| h[k] = [] }
      association_class.find(:all, :conditions => { :session_id => sessions }, :select => 'participant_id, session_id').each do |assoc|
        by_participant[assoc.participant_id] << assoc.session_id
      end
      puts "#{by_participant.count} #{association_class.name.pluralize.humanize.downcase}"
      by_participant.values
    end
  
    def initialize(*args)
      if args.length == 1
        event = args.first
        @sessions = event.session_ids
        @time_slots = event.timeslots
        @max_per_slot = event.rooms.count
        @attendance_sets = Schedule.build_sets @sessions, Attendance
        @presenter_sets  = Schedule.build_sets @sessions, Presentation
      elsif args.length == 5
        @sessions, @time_slots, @max_per_slot, @attendance_sets, @presenter_sets = *args
      else
        raise ArgumentError, 'expected either 1 or 5 args'
      end
    
      @slots_by_session = {}
      @sessions_by_slot = {}
      unassigned = @sessions.shuffle
      @time_slots.each do |slot|
        slot_sessions = unassigned.slice!(0, @max_per_slot)
        slot_sessions << Unassigned.new while slot_sessions.count < @max_per_slot
        slot_sessions.each { |session| @slots_by_session[session] = slot }
        @sessions_by_slot[slot] = slot_sessions
      end
      unless unassigned.empty?
        raise "Not enough room / slot combinations! There are #{@sessions.count} sessions, but only #{@time_slots.count} times slots * #{@max_per_slot} rooms = #{@time_slots.count * @max_per_slot} combinations."
      end
    end
    
    def initialize_copy(source)
      @slots_by_session = @slots_by_session.dup
      @sessions_by_slot = Hash.new { |h,k| h[k] = [] }
      @slots_by_session.each { |session, slot| @sessions_by_slot[slot] << session }
    end
  
    def energy
      overlap_score(@attendance_sets) + overlap_score(@presenter_sets) * @attendance_sets.count
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
      s = "Schedule   average participant can attend #{'%1.3f' % ((1 - self.energy) * 100)}% of their sessions of interest    presenter overlap = #{overlap_score(@presenter_sets)}\n"
      @time_slots.each do |slot|
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





# sched = Scheduling::Schedule.new(
#   %w(soup nuts penguins walruses monkeys chickens ocelots snowboarding windsurfing bobsledding glossolalia),
#   %w(9:00 10:00 11:00 12:00),
#   4,
#   [%w(soup nuts),
#    %w(penguins walruses monkeys chickens),
#    %w(snowboarding windsurfing),
#    %w(glossolalia nuts monkeys),
#    %w(soup nuts penguins walruses monkeys chickens ocelots snowboarding windsurfing bobsledding glossolalia),
#    %w(windsurfing walruses glossolalia ocelots),
#    %w(windsurfing monkeys),
#    %w(windsurfing nuts penguins),
#    %w(snowboarding ocelots monkeys),
#    %w(nuts ocelots chickens),
#    %w(snowboarding glossolalia),
#    %w(chickens soup),
#    %w(penguins soup),
#    %w(snowboarding walruses nuts)],
#   [%w(penguins snowboarding bobsledding),
#    %w(penguins ocelots)])
# 
# p sched
# 
# annealer = Scheduling::Annealer.new(:max_iter => 80000, :cooling_time => 10000000, :repetition_count => 3)
# best = annealer.anneal(sched)
# puts "BEST SOLUTION:"
# p best
