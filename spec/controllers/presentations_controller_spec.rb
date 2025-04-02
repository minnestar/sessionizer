require 'spec_helper'

describe PresentationsController do
  let!(:session) { create(:session) }
  let!(:participant) { create(:joe) }

  describe "#index" do
    it "should be successful" do
      get :index, params: {session_id: session}
      expect(response).to be_successful
      expect(assigns[:presentation]).to be_kind_of Presentation
      expect(assigns[:session]).to eq session
    end
  end

  describe "#create" do
    before do
      create(:event)
    end

    context "when the user is found by id" do
      it "should be successful when the user has signed the code of conduct" do
        CodeOfConductAgreement.create!({
          participant_id: participant.id,
          event_id: Event.current_event.id,
        })

        expect {
          post :create, params: { session_id: session, id: participant.id }
        }.to change { session.reload.presentations.count }.by(1)
        expect(response).to redirect_to session_presentations_path(session)
        expect(flash[:notice]).to eq "Presenter added."
      end

      it 'is unsuccessful when the user hasnt signed the code of conduct' do
        post :create, params: { session_id: session, id: participant.id }
        expect(response).to redirect_to session_presentations_path(session)
        expect(flash[:error]).to match(/hasn\'t signed the current Code of Conduct/)
      end
    end

    context "when the user is found by name" do
      it "should be successful when the user has signed the code of conduct" do
        CodeOfConductAgreement.create!({
          participant_id: participant.id,
          event_id: Event.current_event.id,
        })

        expect {
          post :create, params: { session_id: session, name: participant.name }
        }.to change { session.reload.presentations.count }.by(1)
        expect(response).to redirect_to session_presentations_path(session)
        expect(flash[:notice]).to eq "Presenter added."
      end

      it 'is unsuccessful when the user hasnt signed the code of conduct' do
        post :create, params: { session_id: session, name: participant.name }
        expect(response).to redirect_to session_presentations_path(session)
        expect(flash[:error]).to match(/hasn\'t signed the current Code of Conduct/)
      end
    end

    context "when the user name is not found" do
      it "should set a flash message" do
        expect {
          post :create, params: { session_id: session, name: 'Grace Hopper' }
        }.not_to change { session.reload.presentations.count }
        expect(flash[:error]).to eq "Sorry, no presenter matching 'Grace Hopper' was found. Please try again."
        expect(response).to redirect_to session_presentations_path(session)
      end
    end

    context "when the user id is not found" do
      it "should set a flash message" do
        expect {
          post :create, params: { session_id: session, id: 0 }
        }.not_to change { session.reload.presentations.count }
        expect(flash[:error]).to eq "There was an error adding the presenter. Please try again. If this keeps happening, please contact support@minnestar.org."
        expect(response).to redirect_to session_presentations_path(session)
      end
    end
  end

end
