require 'spec_helper'

describe SchedulesController do
  describe "#index" do
    let!(:event) { FactoryGirl.create(:event, :full_event) }
    let!(:event) { FactoryGirl.create(:event, :full_event) }
    it "should be successful" do
      get :index
      expect(response).to be_successful
      expect(assigns[:event]).to eq event
    end
  end

  describe "#ical" do
    let(:timeslot) { FactoryGirl.create(:timeslot) }
    let!(:session) { FactoryGirl.create(:session, timeslot: timeslot, event: timeslot.event) }

    it "should be successful" do
      get :ical
      expect(response).to be_successful
      expect(response.headers['Content-Type']).to eq 'text/calendar; charset=utf-8'
      expect(response.body).to match /ORGANIZER;CN=Luke Francl:/
    end
  end
end
