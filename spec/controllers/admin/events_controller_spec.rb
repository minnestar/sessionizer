require 'spec_helper'

describe Admin::EventsController do
  describe "#index" do
    let!(:event) { create(:event) }
    it "is successful" do
      get :index
      expect(response).to be_successful
      expect(assigns[:events]).to eq [event]
    end
  end

  describe "#new" do
    it "is successful" do
      get :new
      expect(response).to be_successful
      expect(assigns[:event]).to be_kind_of Event
    end
  end

  describe "#create" do
    it "is successful" do
      expect {
        post :create, params: {event: { name: "My new event", date: '2014-09-12' }}
      }.to change { Event.count }.by(1)
      expect(response).to redirect_to admin_events_path
    end
  end

  describe "#edit" do
    let(:event) { create(:event) }
    it "is successful" do
      get :edit, params: {id: event}
      expect(response).to be_successful
      expect(assigns[:event]).to eq event
    end
  end

  describe "#update" do
    let(:event) { create(:event) }
    it "is successful" do
      patch :update, params: {id: event, event: { name: 'Changed name' }}
      expect(response).to redirect_to admin_events_path
      expect(assigns[:event].name).to eq 'Changed name'
    end
  end
end
