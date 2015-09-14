require 'spec_helper'

describe AdminController do
  describe "#show" do
    it "is successful" do
      expect(controller).to receive(:authenticate)
      get :show
      expect(response).to be_success
    end
  end
end
