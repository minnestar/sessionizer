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

  test "recommended_sessions should order based on recommendation strength" do
    Fixie.sessions(:luke_session).destroy

    comparison_session = Fixie.events(:current_event).sessions.create(:title => 'session 1', :description => 'blah', :participant => Fixie.participants(:luke))

    half_similar = Fixie.events(:current_event).sessions.create(:title => 'session 3', :description => 'blah', :participant => Fixie.participants(:luke))

    # create this one last: natural ordering is by IDs(?), this will throw it off
    equal_session = Fixie.events(:current_event).sessions.create(:title => 'session 2', :description => 'blah', :participant => Fixie.participants(:luke))

    comparison_session.attendances.create(:participant => Fixie.participants(:luke))
    comparison_session.attendances.create(:participant => Fixie.participants(:joe))

    equal_session.attendances.create(:participant => Fixie.participants(:luke))
    equal_session.attendances.create(:participant => Fixie.participants(:joe))

    half_similar.attendances.create(:participant => Fixie.participants(:joe))

    similarity = Session.session_similarity
    assert_equal([[1, equal_session.id], [0.5, half_similar.id]], similarity[comparison_session.id])

    assert_equal([equal_session, half_similar], comparison_session.recommended_sessions)
  end

  test "recommended_sessions should not error if session similarity includes deleted session" do
    session = Fixie.sessions(:luke_session)
    
    Session.stubs(:session_similarity).returns({ session.id => [[1, 123], [0.5, 999]] })

    assert_equal([], session.recommended_sessions)
  end
end
