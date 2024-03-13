require 'spec_helper'

describe SchedulesHelper do
  describe "#session_columns_for_slot" do
    let(:timeslot) { create(:timeslot) }
    let(:event) { timeslot.event }
    let(:room) { create(:room, event: event) }
    let(:presenter) { create(:participant) }
    let!(:session1) { create_session(participant_count: 7) }
    let!(:session2) { create_session(participant_count: 3) }
    let!(:session3) { create_session(participant_count: 10) }
    let!(:session4) { create_session(participant_count: 1) }

    def create_session(participant_count: 1)
      session = create(:session, room: room, timeslot: timeslot, event: event, participant: presenter)
      session.participants = participant_count.times.map { create(:participant) }
      session
    end

    xit "should arange the sessions into two groups" do
      yielded = []
      helper.session_columns_for_slot(timeslot) { |group| yielded << group }
      expect(yielded).to eq [[session3, session1], [session2, session4]]
    end
  end

  describe "#pill_label" do
    let(:slot) { build(:timeslot_1) }
    subject { helper.pill_label(slot) }

    it { is_expected.to eq ' 9:00' }
  end
end
