require 'spec_helper'

describe SchedulesController do
  describe "#index" do
    let!(:event) { create(:event, :full_event) }
    let!(:event) { create(:event, :full_event) }
    it "should be successful" do
      get :index
      expect(response).to be_successful
      expect(assigns[:event]).to eq event
    end
  end

  describe "#ical" do
    let(:timeslot) { create(:timeslot) }
    let!(:session) { create(:session, timeslot: timeslot, event: timeslot.event) }

    it "should be successful" do
      get :ical
      expect(response).to be_successful
      expect(response.headers['Content-Type']).to eq 'text/calendar; charset=utf-8'
      expect(response.body).to match(/ORGANIZER;CN=Luke Francl:/)
    end
  end
end
