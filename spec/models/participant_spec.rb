require 'spec_helper'

describe Participant do
  describe "#restrict_after" do
    let(:event) { FactoryGirl.create(:event) }
    let!(:time1) { FactoryGirl.create(:timeslot_1, event: event) }
    let!(:time2) { FactoryGirl.create(:timeslot_2, event: event) }
    let!(:time3) { FactoryGirl.create(:timeslot_3, event: event) }
    let(:luke) { FactoryGirl.create(:luke) }

    it "should not do anything if there are no timeslots that end after the given time" do
      expect {
        luke.restrict_after(Time.zone.parse("#{event.date.strftime('%Y-%m-%d')} 15:00"))
      }.to_not change { PresenterTimeslotRestriction.count }
    end

    it "should add a restriction for all timeslots that end after the given time" do
      luke.restrict_after(Time.zone.parse("#{event.date.strftime('%Y-%m-%d')} 08:00"))
      expect(luke.presenter_timeslot_restrictions.count).to eq Timeslot.count
    end

    it "should not add restrictions if a timeslot ends before the given time" do
      luke.restrict_after(Time.zone.parse("#{event.date.strftime('%Y-%m-%d')} 10:30"))
      expect(luke.presenter_timeslot_restrictions.map(&:timeslot)).to eq [time2, time3]
    end
  end
end
