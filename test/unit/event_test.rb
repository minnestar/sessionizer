require 'test_helper'

class EventTest < ActiveSupport::TestCase
  context "Event" do
    subject do
      Event.new(:name => 'Foobar', :date => Date.today)
    end
    
    should_validate_presence_of :name, :date
    should_have_many :sessions
    should_have_many :timeslots
    should_have_many :rooms
  end
end
