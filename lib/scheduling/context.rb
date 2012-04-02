module Scheduling
  class Context
    
    attr_reader :sessions, :timeslots, :rooms
  
    def initialize(event)
      @sessions = event.session_ids
      @timeslots = event.timeslots
      @rooms = event.rooms
      
      @attendance_sets = Context.build_sets @sessions, Attendance    # These are both maps from participant_id to array of session_ids
      @presenter_sets  = Context.build_sets @sessions, Presentation
      
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
    end
    
    def attendee_count
      @attendance_sets.count
    end
    
    # Iterates over participants in the given role, which may be either :attendees or :presenters.
    #
    # The given block receives three parameters:
    #  - the presenter,
    #  - an array of sessions in which the presenter has the given role (and thus doesn't want in the same slot), and
    #  - a callback which gives an additional penalty for a given slot.
    #
    # Returns the number of participants yielded.
    def each_session_set(participant_role, &block)
      session_sets, slot_penalties = case participant_role
        when :attendees
          [@attendance_sets, {}]
        when :presenters
          [@presenter_sets, @timeslot_restrictions]
        else
          raise "Unknown role #{participant_role.inspect}"
      end
      session_sets.each do |participant, sessions|
        yield participant, sessions, lambda { |slot| slot_penalties[[participant, slot.id]] || 0 }
      end.count
    end
  
  private
    
    def self.build_sets(sessions, association_class)
      # This brute force iteration is hardly slick, but I'm too rusty on fancy querying in Rails 2.3 to care just now. -PPC
      session_set = Hash.new { |h,k| h[k] = [] }
      association_class.find(:all, :conditions => { :session_id => sessions }, :select => 'participant_id, session_id').each do |assoc|
        session_set[assoc.participant_id] << assoc.session_id
      end
      puts "#{session_set.count} #{association_class.name.pluralize.humanize.downcase}"
      session_set
    end
    
  end
end
