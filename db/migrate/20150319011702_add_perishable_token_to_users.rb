class AddPerishableTokenToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :participants, :perishable_token, :string, :default => "", :null => false
    add_index :participants, :perishable_token
  end
end
