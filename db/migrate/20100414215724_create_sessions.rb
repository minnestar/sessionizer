class CreateSessions < ActiveRecord::Migration
  def self.up
    create_table :sessions do |t|
      t.belongs_to :participant, :null => false
      t.string :title, :null => false
      t.text :description, :null => false
      t.boolean :panel, :null => false, :default => false
      t.boolean :projector, :null => false, :default => false
      
      t.timestamps
    end
  end

  def self.down
    drop_table :sessions
  end
end
