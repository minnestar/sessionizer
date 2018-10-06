require "spec_helper"

describe Session do
  it { should have_many(:categorizations) }
  it { should have_many(:categories) }
  it { should belong_to(:participant) }
  it { should have_many(:presentations) }
  it { should have_many(:presenters) }
  it { should belong_to(:event) }
  it { should belong_to(:timeslot) }
  it { should belong_to(:room) }
  it { should have_many(:attendances) }
  it { should have_many(:participants) }
  it { should validate_presence_of :title }
  it { should validate_presence_of :description }

  let(:event) { create(:event) }
  let(:joe) { create(:joe) }
  let(:luke) { create(:luke) }

  describe "creation" do
    let(:participant) { create(:participant) }
    subject {
      participant.sessions.build(title: 'Some Title', description: 'some desc').tap do |s|
        s.event = event
        s.save!
      end
    }

    it "should create a presenter after create" do
      expect(subject.presentations.size).to eq 1
    end

  end

  describe "destroying" do
    it "should destory categorizations and attendences" do
      session = create(:session, event: event)
      categorization = session.categorizations.build
      categorization.category = Category.first
      categorization.save!
      session.attendances.create(:participant => joe)

      expect {
        expect {
          expect {
            session.destroy
          }.to change { Attendance.count }.by(-1)
        }.to change { Session.count }.by(-1)
      }.to change { Categorization.count }.by(-1)
    end
  end

  it "should allow a blank summary" do
    subject.summary = ''
    subject.valid?
    assert_empty subject.errors[:summary]
  end

  it "should add the owner as a presenter" do
    session = joe.sessions.build(:title => 'hi', :description => 'bye')
    session.event = event
    session.save!
    assert_equal([joe], session.presenters)
  end

  it "should require a unique timeslot and room" do
    room = create(:room)
    slot = create(:timeslot_1)
    Session.new(:title => 'hi', :description => 'bye').tap do |s|
      s.timeslot = slot
      s.room = room
      s.participant = joe
      s.event = event
      s.save!
    end

    session = Session.new.tap do |s|
      s.timeslot = slot
      s.room = room
    end
    session.valid?

    assert session.errors[:timeslot_id]
  end

  it 'should allow rooms to be swapped' do
    room1 = create(:room)
    room2 = create(:room)
    slot1 = create(:timeslot_1)

    Session.new(:title => 'Session 1', :description => 'First session').tap do |s|
      s.timeslot = slot1
      s.room = room1
      s.participant = joe
      s.event = event
      s.save!
    end
    session1 = Session.last
    
    Session.new(:title => 'Session 2', :description => 'Second session').tap do |s|
      s.timeslot = slot1
      s.room = room2
      s.participant = luke
      s.event = event
      s.save!
    end
    session2 = Session.last

    assert_equal(session1.room, room1)
    assert_equal(session2.room, room2)
    Session.swap_rooms(session1, session2)
    assert_equal(session1.room, room2)
    assert_equal(session2.room, room1)
  end

  describe "#recommended_sessions" do

    it "should order based on recommendation strength" do

      comparison_session = event.sessions.create(:title => 'session 1', :description => 'blah').tap do |s|
        s.participant = luke
        s.save!
      end

      half_similar = event.sessions.create(:title => 'session 3', :description => 'blah').tap do |s|
        s.participant = luke
        s.save!
      end

      # create this one last: natural ordering is by IDs(?), this will throw it off
      equal_session = event.sessions.create(:title => 'session 2', :description => 'blah').tap do |s|
        s.participant = luke
        s.save!
      end

      #-make sure we don't have any stale data around
      Rails.cache.delete 'session_similarity'

      comparison_session.attendances.create(:participant => luke)
      comparison_session.attendances.create(:participant => joe)

      equal_session.attendances.create(:participant => luke)
      equal_session.attendances.create(:participant => joe)

      half_similar.attendances.create(:participant => joe)

      similarity = Session.session_similarity()

      assert_equal([[1, equal_session.id], [0.5, half_similar.id]], similarity[comparison_session.id])

      assert_equal([equal_session, half_similar], comparison_session.recommended_sessions)
    end

    it "should not error if session similarity includes deleted session" do
      session = create(:session)

      allow(Session).to receive(:session_similarity).and_return(session.id => [[1, 123], [0.5, 999]])

      assert_equal([], session.recommended_sessions)
    end
  end
end
