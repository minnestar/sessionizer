class CreateEventCategories < ActiveRecord::Migration[7.2]
  def change
    create_table :event_categories do |t|
      t.references :event, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.integer :position, default: 0, null: false

      t.timestamps
    end

    add_index :event_categories, [:event_id, :category_id], unique: true
    add_index :event_categories, [:event_id, :position]
  end
end
