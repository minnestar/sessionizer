class AddManuallyScheduledToSessions < ActiveRecord::Migration[4.2]
  def change
    add_column :sessions, :manually_scheduled, :boolean, null: false, default: false
  end
end
