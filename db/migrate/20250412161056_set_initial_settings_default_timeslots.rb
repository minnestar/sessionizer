class SetInitialSettingsDefaultTimeslots < ActiveRecord::Migration[7.1]
  def up
    settings = Settings.find_or_create_by(id: 1)
    initial_config = JSON.parse(Settings.static_default_timeslots.to_json)
    settings&.update!(default_timeslots: initial_config)
  end

  def down
    settings = Settings.find_by(id: 1)
    settings&.update!(default_timeslots: [])
  end
end
