class AddCounterCachesToSessions < ActiveRecord::Migration[7.1]
  def change
    add_column :sessions, :attendances_count, :integer, default: 0

    reversible do |dir|
      dir.up do
        say_with_time "Updating Session counter caches..." do
          # Use SQL directly to avoid model scopes
          execute <<-SQL
            UPDATE sessions
            SET attendances_count = (
              SELECT COUNT(*)
              FROM attendances
              WHERE attendances.session_id = sessions.id
            )
          SQL
        end
      end
    end
  end
end
