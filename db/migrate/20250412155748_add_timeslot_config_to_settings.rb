class AddTimeslotConfigToSettings < ActiveRecord::Migration[7.1]
  def change
    add_column :settings, :timeslot_config, :jsonb
  end
end
