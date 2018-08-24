class CreateCategorizations < ActiveRecord::Migration[4.2]
  def self.up
    create_table :categorizations do |t|
      t.integer :category_id, :null => false
      t.integer :session_id, :null => false

      t.timestamps
    end

    add_index :categorizations, [:category_id, :session_id], :unique => true
  end

  def self.down
    drop_table :categorizations
  end
end
