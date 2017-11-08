class CreateSettings < ActiveRecord::Migration[4.2]
  def change
    create_table :settings do |t|
      t.boolean :show_schedule
      t.references :current_event, index: true
    end
  end
end
