class AddCounterCachesToEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :events, :sessions_count, :integer, default: 0
    add_column :events, :rooms_count, :integer, default: 0
    add_column :events, :timeslots_count, :integer, default: 0

    reversible do |dir|
      dir.up do
        say_with_time "Updating Event counter caches..." do
          # Use SQL directly to avoid model scopes
          execute <<-SQL
            UPDATE events
            SET sessions_count = (
              SELECT COUNT(*)
              FROM sessions
              WHERE sessions.event_id = events.id
            ),
            rooms_count = (
              SELECT COUNT(*)
              FROM rooms
              WHERE rooms.event_id = events.id
            ),
            timeslots_count = (
              SELECT COUNT(*)
              FROM timeslots
              WHERE timeslots.event_id = events.id
            )
          SQL
        end
      end
    end
  end
end
