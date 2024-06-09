require 'spec_helper'

describe SchedulesController do
  describe "#index" do
    render_views

    before { Rails.cache.clear }

    let!(:event) { create(:event, :full_event) }
    let!(:session) { create(:session, title: "Session #{rand}", event: event, timeslot: event.timeslots.first) }
    let(:user) { create(:participant) }

    context "when settings says to show schedules" do
      before { allow(Settings).to receive(:show_schedule?).and_return(true) }
      it "is successful" do
        get :index
        expect(response).to be_successful
        expect(assigns[:event]).to eq event
        expect(response.body).to match(session.title)
      end
    end

    context "when schedules are not yet displayed" do
      before { allow(Settings).to receive(:show_schedule?).and_return(false) }
      it "redirects" do
        get :index
        expect(response).to redirect_to home_page_path
      end
    end

    context "schedule preview" do
      it "is available to participants" do
        activate_authlogic
        ParticipantSession.create(user)

        get :index, params: {preview: true}
        expect(response).to be_successful
        expect(assigns[:event]).to eq event
        expect(response.body).to match(session.title)
      end

      it "requires login" do
        get :index, params: {preview: true}
        expect(response).to be_redirect
      end
    end
  end

  describe "#ical" do
    let(:timeslot) { create(:timeslot) }
    let!(:session) do
      create(:session,
             event: timeslot.event,
             timeslot: timeslot,
             participant: create(:luke))
    end
    it "is successful" do
      get :ical
      expect(response).to be_successful
      expect(response.headers['Content-Type']).to eq 'text/calendar; charset=utf-8'
      expect(response.body).to match(/ORGANIZER;CN=Luke Francl:/)
    end
  end
end
