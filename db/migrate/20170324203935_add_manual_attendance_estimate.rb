class AddManualAttendanceEstimate < ActiveRecord::Migration[5.0]
  def change
    add_column :sessions, :manual_attendance_estimate, :integer
  end
end
