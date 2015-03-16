class AddLevelToSessions < ActiveRecord::Migration
  def change
    change_table :sessions do |t|
      t.belongs_to :level
      t.index :level_id
    end
  end
end
