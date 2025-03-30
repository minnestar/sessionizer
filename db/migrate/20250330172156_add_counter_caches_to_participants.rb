class AddCounterCachesToParticipants < ActiveRecord::Migration[7.1]
  def change
    add_column :participants, :presentations_count, :integer, default: 0
    add_column :participants, :attendances_count, :integer, default: 0
    
    # using raw SQL to update counter caches here to make this more performant
    reversible do |dir|
      dir.up do
        say_with_time "Updating participant counter caches..." do
          execute <<-SQL
            UPDATE participants 
            SET presentations_count = (
              SELECT COUNT(*)
              FROM presentations
              WHERE presentations.participant_id = participants.id
            ),
            attendances_count = (
              SELECT COUNT(*)
              FROM attendances
              WHERE attendances.participant_id = participants.id
            )
          SQL
        end
      end
    end
  end
end
