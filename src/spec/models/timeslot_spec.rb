# == Schema Information
#
# Table name: timeslots
#
#  id          :integer          not null, primary key
#  event_id    :integer          not null
#  created_at  :datetime
#  updated_at  :datetime
#  starts_at   :datetime
#  ends_at     :datetime
#  schedulable :boolean          default(TRUE)
#  title       :string
#

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

  context "to_s" do
    let(:event) { build(:event, date: Date.parse('2015-09-13')) }
    let(:timeslot) { build(:timeslot_1, event: event) }

    context "when with_day is set" do
      subject { timeslot.to_s(with_day: true) }
      it { is_expected.to eq 'Sun  9:00 –  9:50 Session 1' }
    end

    context "no args" do
      subject { timeslot.to_s }
      it { is_expected.to eq ' 9:00 –  9:50 Session 1' }
    end
  end
end
