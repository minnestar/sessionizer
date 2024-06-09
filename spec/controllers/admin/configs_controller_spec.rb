require 'spec_helper'

describe Admin::ConfigsController do
  describe "#show" do
    it "should be successful" do
      get :show
      expect(response).to be_successful
    end
  end

  describe "#create" do
    it "should be successful" do
      expect {
        post :create, params: {show_schedule: 'true'}
      }.to change { Settings.show_schedule? }.from(false).to(true)
      expect(response).to be_redirect
      expect(flash[:notice]).to eq 'Configuration saved'
    end
  end
end
