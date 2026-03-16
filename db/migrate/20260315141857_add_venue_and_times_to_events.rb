class AddVenueAndTimesToEvents < ActiveRecord::Migration[7.2]
  def change
    add_column :events, :venue, :string, default: "Best Buy HQ"
    add_column :events, :start_time, :datetime, precision: nil
    add_column :events, :end_time, :datetime, precision: nil
  end
end
