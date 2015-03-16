class CreateLevels < ActiveRecord::Migration
  def change
    create_table :levels do |t|
      t.string :name
    end
  end
end
