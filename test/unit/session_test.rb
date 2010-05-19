require 'test_helper'

class SessionTest < ActiveSupport::TestCase
  context "Session" do
    subject do
      Session.new(:participant_id => 123)
    end
    
    should_validate_presence_of :title, :description

    should "destory categorizations and attendences" do
      session = Fixie.sessions(:luke_session)

      assert_difference ['Attendance.count', 'Session.count', 'Categorization.count'], -1 do
        session.destroy
      end
    end
  end
end
