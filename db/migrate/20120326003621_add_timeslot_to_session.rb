class AddTimeslotToSession < ActiveRecord::Migration
  def self.up
    add_column :sessions, :timeslot_id, :integer
  end

  def self.down
    remove_column :session, :timeslot_id
  end
end
