class AddEmailConfirmedAtToParticipants < ActiveRecord::Migration[5.2]
  def change
    add_column :participants, :email_confirmed_at, :datetime
  end
end
