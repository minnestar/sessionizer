class AddCocAgreedAtToParticipants < ActiveRecord::Migration[7.2]
  def change
    add_column :participants, :coc_agreed_at, :datetime
  end
end
