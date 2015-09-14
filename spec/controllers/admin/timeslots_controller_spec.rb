require 'spec_helper'

describe Admin::TimeslotsController do
  let(:event) { create(:event) }

  describe "#index" do
    let!(:timeslot) { create(:timeslot, event: event) }

    it "is successful" do
      get :index, event_id: event
      expect(response).to be_successful
      expect(assigns[:event]).to eq event
      expect(assigns[:timeslots]).to eq [timeslot]
    end
  end

  describe "#new" do
    it "is successful" do
      get :new, event_id: event
      expect(response).to be_successful
      expect(assigns[:event]).to eq event
      expect(assigns[:timeslot]).to be_kind_of Timeslot
    end
  end

  describe "#edit" do
    let(:timeslot) { create(:timeslot, event: event) }

    it "is successful" do
      get :edit, id: timeslot
      expect(response).to be_successful
      expect(assigns[:timeslot]).to eq timeslot
    end
  end

  describe "#update" do
    let(:timeslot) { create(:timeslot, event: event) }

    it "is successful" do
      put :update, id: timeslot, timeslot: { event_id: event, starts_at: '2015-05-03 12:00:00', ends_at: '2015-05-03 12:50:00', schedulable: '1', title: "a changed title" }
      expect(assigns[:timeslot].title).to eq 'a changed title'
      expect(response).to redirect_to admin_event_timeslots_path(event)
    end
  end

  describe "#create" do
    it "is successful" do
      expect {
        post :create, event_id: event, timeslot: { event_id: event, starts_at: '2015-05-03 12:00:00', ends_at: '2015-05-03 12:50:00', schedulable: '1', title: "A timeslot has entered the event!" }
      }.to change { event.timeslots.count }.by(1)
      expect(response).to redirect_to admin_event_timeslots_path
    end
  end
end
