require 'spec_helper'

describe EventsController do
  context "with an event" do
    let!(:event) { create(:event, :full_event) }

    it "should show the sessions" do
      get :show, params: { id: 'current' }
      expect(response).to be_successful
      expect(assigns[:recent_sessions]).to be_empty
      expect(assigns[:categories]).to all(be_kind_of Category)
    end

    context 'in JSON format' do
      it 'is successful' do
        get :show, params: {id: event, format: :json}
        expect(response).to be_successful
        expect(response.content_type).to eq('application/json; charset=utf-8')
      end
    end
  end

  context "without an event" do
    it "should have an empty list of sessions" do
      get :show, params: { id: 'current' }
      expect(response).to be_successful
      expect(assigns[:recent_sessions]).to be_empty
      expect(assigns[:categories]).to all(be_kind_of Category)
    end
  end
end
