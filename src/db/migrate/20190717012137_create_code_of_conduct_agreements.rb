class CreateCodeOfConductAgreements < ActiveRecord::Migration[5.2]
  def change
    create_table :code_of_conduct_agreements do |t|
      t.references :participant, null: false
      t.references :event, null: false
      t.timestamps
    end
  end
end
