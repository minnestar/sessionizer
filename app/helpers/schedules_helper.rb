module SchedulesHelper
  def session_columns_for_slot(slot, num_cols = 2, &block)
    sessions = slot.sessions.sort_by { |s| -s.room.capacity }
    split = sessions.length / 2 + 1
    yield sessions[0...split]
    yield sessions[split..-1]
  end
end
