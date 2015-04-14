class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.boolean :show_schedule
      t.references :current_event, index: true
    end
  end
end
