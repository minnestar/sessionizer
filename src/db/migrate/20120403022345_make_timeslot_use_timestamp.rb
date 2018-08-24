class MakeTimeslotUseTimestamp < ActiveRecord::Migration[4.2]
  def self.up
    remove_column :timeslots, :starts_at
    remove_column :timeslots, :ends_at

    add_column :timeslots, :starts_at, :timestamp
    add_column :timeslots, :ends_at, :timestamp
  end

  def self.down
    remove_column :timeslots, :starts_at
    remove_column :timeslots, :ends_at
    
    add_column :timeslots, :starts_at, :time
    add_column :timeslots, :ends_at, :time
  end
end
