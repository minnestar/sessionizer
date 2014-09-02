require 'spec_helper'

describe SchedulesHelper do
  describe "#session_columns_for_slot" do
    let(:timeslot) { FactoryGirl.create(:timeslot) }
    let(:event) { timeslot.event }
    let(:room) { FactoryGirl.create(:room, event: event) }
    let(:participant) { FactoryGirl.create(:participant) }
    let!(:session1) { FactoryGirl.create(:session, room: room, timeslot: timeslot, event: event, participant: participant) }
    let!(:session2) { FactoryGirl.create(:session, room: room, timeslot: timeslot, event: event, participant: participant) }
    let!(:session3) { FactoryGirl.create(:session, room: room, timeslot: timeslot, event: event, participant: participant) }
    let!(:session4) { FactoryGirl.create(:session, room: room, timeslot: timeslot, event: event, participant: participant) }

    it "should arange the sessions into two groups" do
      yielded = []
      helper.session_columns_for_slot(timeslot) { |group| yielded << group }
      expect(yielded).to eq [[session1, session3], [session2, session4]]
    end
  end
end
