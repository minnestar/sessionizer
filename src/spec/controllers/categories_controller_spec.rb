require 'spec_helper'

describe CategoriesController do
  describe "#show" do
    let(:category) { Category.first }
    let!(:session) { create(:session, category_ids: [category.id]) }

    it "should be successful" do
      get :show, params: {id: category}
      expect(response).to be_successful
      expect(assigns[:category]).to eq category
      expect(assigns[:sessions]).to eq [session]
    end
  end
end
