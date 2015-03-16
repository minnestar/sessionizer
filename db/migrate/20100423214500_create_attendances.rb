class CreateAttendances < ActiveRecord::Migration
  def self.up
    create_table :attendances do |t|
      t.belongs_to :session, :null => false
      t.belongs_to :participant, :null => false

      t.timestamps
    end

    add_index :attendances, [:session_id, :participant_id], :unique => true
  end

  def self.down
    drop_table :attendances
  end
end
