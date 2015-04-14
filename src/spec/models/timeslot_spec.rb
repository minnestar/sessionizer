require 'spec_helper'

describe Timeslot do
  it { should validate_presence_of :event_id }
  it { should validate_presence_of :starts_at }
  it { should validate_presence_of :ends_at }
  it { should belong_to :event }

  context "#destroy" do
    it "destroys associated PresenterTimeslotRestrictions" do
      timeslot = FactoryGirl.create(:timeslot)
      FactoryGirl.create(:presenter_timeslot_restriction, timeslot: timeslot)

      expect { timeslot.destroy }.to change { PresenterTimeslotRestriction.count }.by(-1)
    end
  end
end
