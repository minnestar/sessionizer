class AddSchedulableToRoom < ActiveRecord::Migration[4.2]
  def change
    add_column :rooms, :schedulable, :boolean, default: true
  end
end
