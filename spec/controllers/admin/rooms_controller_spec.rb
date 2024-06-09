require 'spec_helper'

describe Admin::RoomsController do
  let(:event) { create(:event, date: Date.parse('2015-10-15')) }

  describe "#new" do
    it "is successful" do
      get :new, params: { event_id: event }
      expect(response).to be_successful
      expect(assigns[:event]).to eq event
      expect(assigns[:room]).to be_kind_of Room
    end
  end

  describe "#edit" do
    let(:room) { create(:room, event: event) }

    it "is successful" do
      get :edit, params: { id: room }
      expect(response).to be_successful
      expect(assigns[:room]).to eq room
    end
  end

  describe "#update" do
    let(:room) { create(:room, event: event) }

    it "is successful" do
      put :update, params: { id: room, room: { event_id: event, name: 'Green room', capacity: '25' } }
      expect(assigns[:room].name).to eq 'Green room'
      expect(response).to redirect_to admin_event_path(event)
    end
  end

  describe "#create" do
    it "is successful" do
      expect {
        post :create, params: { event_id: event, room: { event_id: event, name: 'Green room', capacity: '25' } }
      }.to change { event.rooms.count }.by(1)
      expect(response).to redirect_to admin_event_path(event)
    end
  end
end
