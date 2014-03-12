require 'test_helper'

class EventTest < ActiveSupport::TestCase
  context "Event" do
    subject do
      Event.new(:name => 'Foobar', :date => Date.today)
    end
    
    should validate_presence_of :name
    should validate_presence_of :date
    should have_many :sessions
    should have_many :timeslots
    should have_many :rooms
  end
end
