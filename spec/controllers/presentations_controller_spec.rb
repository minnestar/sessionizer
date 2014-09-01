require 'spec_helper'

describe PresentationsController do
  let(:session) { FactoryGirl.create(:session) }
  describe "#index" do
    it "should be successful" do
      get :index, session_id: session
      expect(response).to be_successful
      expect(assigns[:presentation]).to be_kind_of Presentation
      expect(controller.send(:parent_object)).to eq session
    end
  end

  describe "#create" do
    context "when the user exists" do
      before { FactoryGirl.create(:joe) }

      it "should be successful" do
        expect {
          post :create, session_id: session, name: 'Joe Schmoe'
        }.to change { session.presentations.count }.by(1)
        expect(response).to redirect_to session_presentations_path(session)
        expect(flash[:notice]).to eq "Presenter added."
      end
    end

    context "when the user is not found" do
      it "should set a flash message" do
        expect {
          post :create, session_id: session, name: 'Grace Hopper'
        }.not_to change { session.presentations.count }
        expect(flash[:error]).to eq "Sorry, no presenter named 'Grace Hopper' was found. Please try again."
        expect(response).to redirect_to session_presentations_path(session)
      end
    end
  end

end
