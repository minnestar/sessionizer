require 'spec_helper'

RSpec.describe PagesController do
  context "with an event" do
    let!(:event) { create(:event, :full_event) }
    let!(:scheduled_break) do
       create(:session,
              title: 'Break time',
              event: event,
              room: event.rooms.first,
              participant: create(:participant),
              timeslot: event.timeslots.first )
    end
    let!(:proposed_session) do
       create(:session, title: 'How to break things', event: event, room: nil)
    end

    it "shows the sessions" do
      get :home
      expect(response).to be_successful
      # We are implicitly testing that scheduled_break is not in either set
      expect(assigns[:recent_sessions]).to eq [proposed_session]
      expect(assigns[:random_sessions]).to eq [proposed_session]

      expect(assigns[:categories]).to all(be_kind_of Category)
    end
  end

  context "without an event" do
    it "has an empty list of sessions" do
      get :home
      expect(response).to be_successful
      expect(assigns[:recent_sessions]).to be_empty
      expect(assigns[:categories]).to all(be_kind_of Category)
    end
  end
end
