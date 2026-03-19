class AddFieldsToCategories < ActiveRecord::Migration[7.2]
  def change
    add_column :categories, :long_name, :string
    add_column :categories, :tagline, :string
    add_column :categories, :description, :text
    add_column :categories, :active, :boolean, default: true, null: false
    add_column :categories, :default_position, :integer, default: 0, null: false
  end
end
