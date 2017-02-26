require 'spec_helper'

describe SchedulesController do
  describe "#index" do
    before { Rails.cache.clear }
    context "when settings says to show schedules" do
      before { allow(Settings).to receive(:show_schedule?).and_return(true) }
      let!(:event) { create(:event, :full_event) }
      it "is successful" do
        expect(controller).to receive(:event).with(true).and_call_original
        get :index
        expect(response).to be_successful
        expect(assigns[:event]).to eq event
      end
    end

    context "when schedules are not yet displayed" do
      before { allow(Settings).to receive(:show_schedule?).and_return(false) }
      it "redirects" do
        get :index
        expect(response).to redirect_to home_page_path
      end
    end

    context "when schedules are not yet displayed, but they really want to see it anyway" do
      let!(:event) { create(:event, :full_event) }
      it "is successful" do
        expect(controller).to receive(:event).with(false).and_call_original
        get :index, params: {force: true}
        expect(response).to be_successful
        expect(assigns[:event]).to eq event
      end
    end
  end

  describe "#ical" do
    let(:timeslot) { create(:timeslot) }
    let!(:session) { create(:session, timeslot: timeslot, event: timeslot.event) }

    it "is successful" do
      get :ical
      expect(response).to be_successful
      expect(response.headers['Content-Type']).to eq 'text/calendar; charset=utf-8'
      expect(response.body).to match(/ORGANIZER;CN=Luke Francl:/)
    end
  end
end
