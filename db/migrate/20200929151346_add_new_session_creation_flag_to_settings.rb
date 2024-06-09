class AddNewSessionCreationFlagToSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :settings, :allow_new_sessions, :boolean, default: true, null: false
  end
end
