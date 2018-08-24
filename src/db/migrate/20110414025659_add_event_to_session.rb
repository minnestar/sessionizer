class AddEventToSession < ActiveRecord::Migration[4.2]
  def self.up
    add_column :sessions, :event_id, :int
  end

  def self.down
    remove_column :sessions, :event_id
  end
end
