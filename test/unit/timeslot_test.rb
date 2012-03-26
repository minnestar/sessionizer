require 'test_helper'

class TimeslotTest < ActiveSupport::TestCase
  context "Timeslot" do
    should_validate_presence_of :event_id, :starts_at, :ends_at
    should_belong_to :event
  end
end
