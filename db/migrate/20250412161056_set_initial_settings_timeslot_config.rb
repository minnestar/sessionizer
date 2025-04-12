class SetInitialSettingsTimeslotConfig < ActiveRecord::Migration[7.1]
  def up
    settings = Settings.find_or_create_by(id: 1)
    initial_config = JSON.parse(Settings.static_default_timeslot_config.to_json)
    settings.update!(timeslot_config: initial_config)
  end

  def down
    settings = Settings.find_by(id: 1)
    settings&.update!(timeslot_config: [])
  end
end
