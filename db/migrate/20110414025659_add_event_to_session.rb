class AddEventToSession < ActiveRecord::Migration
  def self.up
    add_column :sessions, :event_id, :int
  end

  def self.down
    remove_column :sessions, :event_id
  end
end
