class AddSummaryToSession < ActiveRecord::Migration[4.2]
  def self.up
    add_column :sessions, :summary, :string
  end

  def self.down
    remove_column :sessions, :summary
  end
end
