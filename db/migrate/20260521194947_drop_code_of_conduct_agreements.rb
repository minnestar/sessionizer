class DropCodeOfConductAgreements < ActiveRecord::Migration[7.2]
  def up
    drop_table :code_of_conduct_agreements
  end

  def down
    create_table :code_of_conduct_agreements do |t|
      t.bigint :participant_id, null: false
      t.bigint :event_id, null: false
      t.timestamps precision: nil, null: false
    end

    add_index :code_of_conduct_agreements, :event_id
    add_index :code_of_conduct_agreements, :participant_id
  end
end
