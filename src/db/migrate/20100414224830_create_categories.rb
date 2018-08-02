class CreateCategories < ActiveRecord::Migration[4.2]
  def self.up
    create_table :categories do |t|
      t.string :name, :null => false
    end

    add_index :categories, :name, :unique => true
  end

  def self.down
    drop_table :categories
  end
end
