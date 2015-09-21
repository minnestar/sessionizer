require 'spec_helper'

describe SchedulesHelper do
  describe "#session_columns_for_slot" do
    let(:timeslot) { create(:timeslot) }
    let(:event) { timeslot.event }
    let(:room) { create(:room, event: event) }
    let(:participant) { create(:participant) }
    let!(:session1) { create_session }
    let!(:session2) { create_session }
    let!(:session3) { create_session }
    let!(:session4) { create_session }

    def create_session
      create(:session, room: room, timeslot: timeslot, event: event, participant: participant)
    end

    it "should arange the sessions into two groups" do
      yielded = []
      helper.session_columns_for_slot(timeslot) { |group| yielded << group }
      expect(yielded).to eq [[session1, session3], [session2, session4]]
    end
  end

  describe "#pill_label" do
    let(:slot) { build(:timeslot_1) }
    subject { helper.pill_label(slot) }

    it { is_expected.to eq ' 9:00' }
  end
end
