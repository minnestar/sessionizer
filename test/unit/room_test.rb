require 'test_helper'

class RoomTest < ActiveSupport::TestCase
  context "Room" do
    subject { Fixie.events(:current_event).rooms.create!(:name => 'Asdf', :capacity => 100) }
    should have_many :sessions
    should belong_to :event

    should validate_numericality_of :capacity
    should validate_presence_of :event_id
    should validate_presence_of :name
    should validate_uniqueness_of(:name).scoped_to(:event_id)
  end
  
end
