module SchedulesHelper
  def session_columns_for_slot(slot, num_cols = 2, &block)
    sessions = slot.sessions.sort do |s1, s2|
      capacity = -(s1.room.capacity <=> s2.room.capacity)
      if capacity == 0
        s1.room.name <=> s2.room.name
      else
        capacity
      end
    end
    split = sessions.length / 2 + 1
    yield sessions[0...split]
    yield sessions[split..-1]
  end
end
