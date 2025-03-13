class AddNotNullConstraintsToParticipants < ActiveRecord::Migration[7.1]
  def change
    # update any existing NULL values, just in case
    Participant.where(email: nil).update_all(email: 'INVALID')
    Participant.where(crypted_password: nil).update_all(crypted_password: 'INVALID')

    change_column_null :participants, :email, false
    change_column_null :participants, :crypted_password, false
  end

  def down
    change_column_null :participants, :email, true
    change_column_null :participants, :crypted_password, true
  end
end
