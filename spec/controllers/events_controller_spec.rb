require 'spec_helper'

describe EventsController do
  context "with an event" do
    let!(:event) { create(:event, :full_event) }

    before do
      Category.active.each_with_index do |cat, i|
        create(:event_category, event: event, category: cat, position: i + 1)
      end
    end

    it "should show the sessions" do
      get :show, params: { id: 'current' }
      expect(response).to be_successful
      expect(assigns[:recent_sessions]).to be_empty
      expect(assigns[:categories]).to all(be_kind_of Category)
    end

    it "should return only the event's categories" do
      get :show, params: { id: 'current' }
      expect(assigns[:categories]).to match_array(event.categories)
    end

    it "should return categories ordered by position" do
      get :show, params: { id: 'current' }
      positions = event.event_categories.where(category: assigns[:categories]).ordered.pluck(:position)
      expect(positions).to eq positions.sort
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
    end
  end
end
