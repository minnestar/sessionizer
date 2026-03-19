require 'spec_helper'

describe CategoriesController do
  describe "#show" do
    let(:category) { Category.first }
    let!(:event) { create(:event) }
    let!(:session) { create(:session, event: event, category_ids: [category.id]) }

    it "should be successful" do
      get :show, params: {id: category}
      expect(response).to be_successful
      expect(assigns[:category]).to eq category
      expect(assigns[:sessions]).to eq [session]
    end

    it "should only show sessions from the current event" do
      old_event = create(:event, date: 2.months.ago)
      old_session = create(:session, event: old_event, category_ids: [category.id])

      get :show, params: {id: category}
      expect(assigns[:sessions]).to eq [session]
      expect(assigns[:sessions]).not_to include(old_session)
    end
  end
end
