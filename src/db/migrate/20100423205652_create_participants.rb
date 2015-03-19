class CreateParticipants < ActiveRecord::Migration
  def self.up
    create_table :participants do |t|
      t.string :name
      t.string :email
      t.text :bio
      
      t.timestamps
    end

    add_index :participants, :email, :unique => true
  end

  def self.down
    drop_table :participants
  end
end
