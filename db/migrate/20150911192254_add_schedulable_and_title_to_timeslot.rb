class AddSchedulableAndTitleToTimeslot < ActiveRecord::Migration
  def change
    add_column :timeslots, :schedulable, :boolean, default: true
    add_column :timeslots, :title, :string
  end
end
