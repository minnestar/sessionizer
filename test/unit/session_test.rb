require 'test_helper'

class SessionTest < ActiveSupport::TestCase
  context "Session" do
    subject do
      Session.new(:participant_id => 123)
    end
    
    should_validate_presence_of :title, :description
  end
end
