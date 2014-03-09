require 'test_helper'

class TimeslotTest < ActiveSupport::TestCase
  context "Timeslot" do
    should validate_presence_of :event_id
    should validate_presence_of :starts_at
    should validate_presence_of :ends_at
    should belong_to :event
  end
end
