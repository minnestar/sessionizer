class AddSchedulableAndTitleToTimeslot < ActiveRecord::Migration[4.2]
  def change
    add_column :timeslots, :schedulable, :boolean, default: true
    add_column :timeslots, :title, :string
  end
end
