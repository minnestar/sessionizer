class AddPresentations < ActiveRecord::Migration
  def self.up
    create_table :presentations, :force => true do |t|
      t.integer :session_id
      t.integer :participant_id
      t.timestamps
    end
  end

  def self.down
    drop_table :presentations
  end
end