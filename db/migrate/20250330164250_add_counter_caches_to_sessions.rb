class AddCounterCachesToSessions < ActiveRecord::Migration[7.1]
  def change
    add_column :sessions, :attendances_count, :integer, default: 0

    reversible do |dir|
      dir.up do
        say_with_time "Updating Session counter caches..." do
          Session.find_each { |session| Session.reset_counters(session.id, :attendances) }
        end
      end
    end
  end
end
