class AddManuallyScheduledToSessions < ActiveRecord::Migration
  def change
    add_column :sessions, :manually_scheduled, :boolean, null: false, default: false
  end
end
