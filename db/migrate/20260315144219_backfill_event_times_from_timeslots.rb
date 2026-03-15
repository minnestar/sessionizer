class BackfillEventTimesFromTimeslots < ActiveRecord::Migration[7.2]
  def up
    Event.find_each do |event|
      timeslots = event.timeslots.order(:starts_at)
      next if timeslots.empty?

      event.update_columns(
        start_time: timeslots.first.starts_at,
        end_time: timeslots.last.ends_at
      )
    end
  end

  def down
    Event.update_all(start_time: nil, end_time: nil)
  end
end
