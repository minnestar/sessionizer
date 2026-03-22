class AddDefaultRoomsToSettings < ActiveRecord::Migration[7.2]
  def change
    add_column :settings, :default_rooms, :jsonb
  end
end
