class AddDefaultTimeslotsToSettings < ActiveRecord::Migration[7.1]
  def change
    add_column :settings, :default_timeslots, :jsonb
  end
end
