require 'spec_helper'

describe Admin::EventsController do
  describe "#index" do
    let!(:event) { create(:event) }
    it "should be successful" do
      get :index
      expect(response).to be_successful
      expect(assigns[:events]).to eq [event]
    end
  end

  describe "#new" do
    it "should be successful" do
      get :new
      expect(response).to be_successful
      expect(assigns[:event]).to be_kind_of Event
    end
  end

  describe "#create" do
    it "should be successful" do
      expect {
        post :create, event: { name: "My new event", date: '2014-09-12' }
      }.to change { Event.count }.by(1)
      expect(response).to redirect_to admin_events_path
    end
  end
end
