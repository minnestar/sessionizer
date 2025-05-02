class AddCanceledAtToSessions < ActiveRecord::Migration[7.1]
  def change
    add_column :sessions, :canceled_at, :datetime
  end
end 