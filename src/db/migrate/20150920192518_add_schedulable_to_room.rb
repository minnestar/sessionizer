class AddSchedulableToRoom < ActiveRecord::Migration
  def change
    add_column :rooms, :schedulable, :boolean, default: true
  end
end
