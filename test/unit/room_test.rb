require 'test_helper'

class RoomTest < ActiveSupport::TestCase
  context "Room" do
    subject { Fixie.events(:current_event).rooms.create!(:name => 'Asdf', :capacity => 100) }
    should_have_many :sessions
    should_belong_to :event

    should_validate_numericality_of :capacity
    should_validate_presence_of :event_id, :name
    should_validate_uniqueness_of :name, :scoped_to => :event_id
  end
  
end
