require 'spec_helper'

describe ParticipantsController do
  let(:participant) { create(:participant) }

  describe "#index" do
    let!(:participant) { create(:participant, name: 'one two three', email: 'test@example.org') }

    it "should be successful" do
      get :index, format: :json
      expect(response).to be_successful
      json = JSON.parse(response.body)
      expect(json).to eq [ { "value"=>'one two three', "tokens"=>["one", "two", "three"], "id"=>participant.id } ]
    end
  end

  describe "#new" do
    it "should be successful" do
      get :new
      expect(response).to be_successful
      expect(assigns(:participant)).to be_kind_of Participant
    end
  end

  describe "#create" do
    it "should be successful" do
      post :create, participant: { name: 'Alan Turing', email: 'tapewriter@example.org', password: 'infinite-memory' }
      expect(response).to redirect_to root_path
      expect(flash[:notice]).to eq "Thanks for registering an account. You may now create sessions and mark sessions you'd like to attend."
    end
  end

  describe "#show" do
    it "should be successful" do
      get :show, id: participant
      expect(response).to be_successful
      expect(assigns(:participant)).to be_kind_of Participant
    end
  end

  context "when the logged in user operates on someone elses record" do
    describe "#edit" do
      it "should be successful" do
        get :edit, id: participant
        expect(response).to be_redirect
      end
    end

    describe "#update" do
      it "should be successful" do
        put :update, id: participant, participant: { name: 'Alan Kay' }
        expect(response).to be_redirect
        expect(participant.reload.name).to_not eq 'Alan Kay'
      end
    end
  end

  context "when the logged in user operates on their own record" do
    before do
      activate_authlogic
      ParticipantSession.create(participant)
    end

    describe "#edit" do
      it "should be successful" do
        get :edit, id: participant
        expect(response).to be_successful
        expect(assigns(:participant)).to be_kind_of Participant
      end
    end

    describe "#update" do
      it "should be successful" do
        put :update, id: participant, participant: { name: 'Alan Kay' }
        expect(response).to redirect_to participant
        expect(participant.reload.name).to eq 'Alan Kay'
      end
    end
  end
end
