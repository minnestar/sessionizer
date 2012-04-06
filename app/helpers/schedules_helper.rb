module SchedulesHelper
  def session_columns_for_slot(slot, num_cols = 2, &block)
    # Attempt to divide thes sessions into two roughly equal groups of roughly equal height.
    # (Without this, the fully expanded details grow very lopsided.)
    
    unassigned = slot.sessions.sort_by { |s| -estimated_height(s) }
    
    columns = [[], []]
    heights = [0, 0]
    i = 0
    first = true
    until unassigned.empty?
      if unassigned.size == 1 && columns[0].size == columns[1].size  # odd number of sessions, so last one can go in either column
        i = if heights[0] < heights[1]
          0
        else
          1
        end
      end
      
      if first
        # Start by placing longest description
        session = unassigned.shift
        first = false
      else
        # Greedy algo: choose next session to try to keep heights as close as possible
        desired_height = heights[1-i] - heights[i]
        session = nil
        best_diff = 1 / 0.0
        unassigned.each do |candidate|  # O(n^2), so watch this one if we start assigning lots of sessions per slot!
          diff = (estimated_height(candidate) - desired_height).abs
          if diff < best_diff
            best_diff = diff
            session = candidate
          end
        end
        unassigned.delete(session)
      end
      break unless session
      
      columns[i] << session
      heights[i] += estimated_height(session)
      i = 1-i
    end
    
    # Now yield each column with session sorted by room size.
    
    columns.each do |column|
      yield column.sort_by { |s| [-s.room.capacity, s.room.name] }
    end
  end

private

  def estimated_height(session)
    session[:estimated_height] ||= begin
      h = 0
      h += (session.title.length / 42 + 1) * 25
      h += (session.presenters.size / 5 + 1) * 20
      h += session.description.length / 4 + 17
      session.presenters.each { |presenter| h += (presenter.bio || '').length / 5 + 30}
      h
    end
  end

end
