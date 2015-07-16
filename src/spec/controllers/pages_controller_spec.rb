require 'spec_helper'

describe PagesController do
  context "with an event" do
    let!(:event) { create(:event, :full_event) }

    it "should show the sessions" do
      get :home
      expect(response).to be_successful
      expect(assigns[:recent_sessions]).to be_empty
      expect(assigns[:categories]).to all(be_kind_of Category)
    end
  end

  context "without an event" do
    it "should have an empty list of sessions" do
      get :home
      expect(response).to be_successful
      expect(assigns[:recent_sessions]).to be_empty
      expect(assigns[:categories]).to all(be_kind_of Category)
    end
  end
end
