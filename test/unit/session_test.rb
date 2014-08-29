require 'test_helper'

class SessionTest < ActiveSupport::TestCase
  context "Session" do
    setup do
      @event = FactoryGirl.create(:event)
    end

    subject do
      Session.new(:participant_id => 123)
    end

    should validate_presence_of :title
    should validate_presence_of :description
    should belong_to :timeslot
    should belong_to :room

    should "destory categorizations and attendences" do
      session = FactoryGirl.create(:luke_session, event: @event)
      session.categorizations.create!(:category => Category.first)
      session.attendances.create(:participant => FactoryGirl.create(:joe))

      assert_difference ['Attendance.count', 'Session.count', 'Categorization.count'], -1 do
        session.destroy
      end
    end

    should "allow a blank summary" do
      subject.summary = ''
      subject.valid?
      assert_empty subject.errors[:summary]
    end

    should "add the owner as a presenter" do
      joe = FactoryGirl.create(:joe)
      session = joe.sessions.build(:title => 'hi', :description => 'bye')
      session.event = @event
      session.save!
      assert_equal([joe], session.presenters)
    end

    should "require a unique timeslot and room" do
      room = FactoryGirl.create(:room)
      slot = FactoryGirl.create(:timeslot_1)
      Session.new(:title => 'hi', :description => 'bye').tap do |s|
        s.timeslot = slot
        s.room = room
        s.participant = FactoryGirl.create(:joe)
        s.event = FactoryGirl.create(:event)
        s.save!
      end

      session = Session.new.tap do |s|
        s.timeslot = slot
        s.room = room
      end
      session.valid?

      assert session.errors[:timeslot_id]
    end
  end

  test "recommended_sessions should order based on recommendation strength" do
    current_event = FactoryGirl.create(:event)
    joe = FactoryGirl.create(:joe)
    luke = FactoryGirl.create(:luke)

    comparison_session = current_event.sessions.build(:title => 'session 1', :description => 'blah').tap do |s|
      s.participant = luke
      s.save!
    end

    half_similar = current_event.sessions.create(:title => 'session 3', :description => 'blah').tap do |s|
      s.participant = luke
      s.save!
    end

    # create this one last: natural ordering is by IDs(?), this will throw it off
    equal_session = current_event.sessions.create(:title => 'session 2', :description => 'blah').tap do |s|
      s.participant = luke
      s.save!
    end

    comparison_session.attendances.create(:participant => luke)
    comparison_session.attendances.create(:participant => joe)

    equal_session.attendances.create(:participant => luke)
    equal_session.attendances.create(:participant => joe)

    half_similar.attendances.create(:participant => joe)

    similarity = Session.session_similarity
    assert_equal([[1, equal_session.id], [0.5, half_similar.id]], similarity[comparison_session.id])

    assert_equal([equal_session, half_similar], comparison_session.recommended_sessions)
  end

  test "recommended_sessions should not error if session similarity includes deleted session" do
    session = FactoryGirl.create(:luke_session)

    Session.stubs(:session_similarity).returns({ session.id => [[1, 123], [0.5, 999]] })

    assert_equal([], session.recommended_sessions)
  end
end
