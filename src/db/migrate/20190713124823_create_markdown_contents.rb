class CreateMarkdownContents < ActiveRecord::Migration[5.2]
  def change
    create_table :markdown_contents do |t|
      t.string :name, null: false
      t.string :slug, null: false, index: { unique: true }
      t.string :markdown, null: false

      t.timestamps
    end
  end
end
