class AddCounterCachesToEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :events, :sessions_count, :integer, default: 0
    add_column :events, :rooms_count, :integer, default: 0
    add_column :events, :timeslots_count, :integer, default: 0

    reversible do |dir|
      dir.up do
        say_with_time "Updating counter caches..." do
          Event.find_each { |event| Event.reset_counters(event.id, :sessions, :rooms, :timeslots) }
        end
      end
    end
  end
end
