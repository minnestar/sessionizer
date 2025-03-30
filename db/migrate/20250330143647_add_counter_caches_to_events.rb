class AddCounterCachesToEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :events, :sessions_count, :integer, default: 0
    add_column :events, :rooms_count, :integer, default: 0
    add_column :events, :timeslots_count, :integer, default: 0
  end
end
