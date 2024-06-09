require 'spec_helper'

describe Participant do

  describe "github profile url" do
    let(:luke)  { create(:luke) }

    it "can be constructed with a github username" do
      expect(luke.github_profile_url).to eq "https://github.com/look"
    end
  end

  describe "timeslot restrictions" do
    let(:event) { create(:event) }
    let!(:time1) { create(:timeslot_1, event: event) }
    let!(:time2) { create(:timeslot_2, event: event) }
    let!(:time3) { create(:timeslot_3, event: event) }
    let(:luke)  { create(:luke) }

    describe "#restrict_after" do

      it "should not do anything if there are no timeslots that end after the given time" do
        expect {
          time = Time.zone.parse("#{event.date.strftime('%Y-%m-%d')} 15:00")
          luke.restrict_after(time, 1, event)
        }.to_not change { PresenterTimeslotRestriction.count }
      end

      it "should add a restriction for all timeslots that end after the given time" do
        time = Time.zone.parse("#{event.date.strftime('%Y-%m-%d')} 8:00")
        luke.restrict_after(time, 1, event)
        expect(luke.presenter_timeslot_restrictions.count).to eq Timeslot.count
      end

      it "should not add restrictions if a timeslot ends before the given time" do
        time = Time.zone.parse("#{event.date.strftime('%Y-%m-%d')} 10:30")
        luke.restrict_after(time, 1, event)
        expect(luke.presenter_timeslot_restrictions.map(&:timeslot)).to eq [time2, time3]
      end
    end

    describe "#restrict_before" do
      it "should not do anything if there are no timeslots that end after the given time" do
        time = Time.zone.parse("#{event.date.strftime('%Y-%m-%d')} 10:30")
        luke.restrict_before(time, 1, event)
        expect(luke.presenter_timeslot_restrictions.map(&:timeslot)).to eq [time1, time2]
      end
    end
  end

  describe '#attending session' do
    let!(:session1) { create(:session) }
    let!(:joe)  { create(:joe) }  

    it 'the attending_session? method should yield false when user has not expressed interest in session' do
      expect(joe.attending_session?(session1)).to eq false
    end

    it 'the attending_session? method should yield true when user has expressed interest in session' do
      Attendance.create(participant_id: joe.id,
                        session_id: session1.id)
      expect(joe.attending_session?(session1)).to eq true
    end
  end
end
