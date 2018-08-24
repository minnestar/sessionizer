class CreateTimeslots < ActiveRecord::Migration[4.2]
  def self.up
    create_table :timeslots do |t|
      t.belongs_to :event, :null => false
      t.time :starts_at, :null => false
      t.time :ends_at, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :timeslots
  end
end
