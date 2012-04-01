class CreatePresenterTimeslotRestrictions < ActiveRecord::Migration
  def self.up
    create_table :presenter_timeslot_restrictions, :force => true do |t|
      t.integer :participant_id
      t.integer :timeslot_id
      t.float   :weight
      t.timestamps
    end
    add_index :presenter_timeslot_restrictions, [:timeslot_id, :participant_id], :unique => true, :name => 'present_timeslot_participant_unique'
  end

  def self.down
    drop_table :presenter_timeslot_restrictions
  end
end
