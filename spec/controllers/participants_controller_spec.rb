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
      post :create, params: { participant: { name: 'Alan Turing', 
                                   email: 'tapewriter@example.org', 
                                   password: 'infinite-memory'
                             }
      }
      expect(response).to redirect_to root_path
      expect(flash[:notice]).to eq "Thanks for registering an account. You may now create sessions and mark sessions you'd like to attend."
    end
  end

  describe "#show" do
    it "should be successful" do
      get :show, params: {id: participant}
      expect(response).to be_successful
      expect(assigns(:participant)).to be_kind_of Participant
    end
  end

  context "when the logged in user operates on someone elses record" do
    let(:luke) { create(:luke) }
    before do
      activate_authlogic
      ParticipantSession.create(luke)
    end
      
    describe "#edit" do
      it "should be not be allowed" do
        get :edit, params: {id: participant}
        expect(response).to be_redirect
      end
    end

    describe "#update" do
      it "will not be allowed" do
        put :update, params: {id: participant, participant: { name: 'Alan Kay' }}
        expect(response).to be_redirect
        expect(participant.reload.name).to_not eq 'Alan Kay'
      end
    end
  end

  context "when the logged in user operates on their own record" do
    before do
      activate_authlogic
      ParticipantSession.create(joe)
    end
    let(:joe) { create(:joe) }

    describe "#edit" do
      it "should be successful" do
        get :edit, params: {id: joe}
        expect(response).to be_successful
        expect(assigns(:participant)).to be_kind_of Participant
      end
    end

    describe "#update" do
      it "should be successful" do
        put :update, params: {id: joe, participant: { name: 'schmoe, joe' }}
        expect(response).to redirect_to joe
        expect(joe.reload.name).to eq 'schmoe, joe'
      end

      describe "more attributes are not required" do
        it "should be successful" do
          put :update, params: {id: joe, participant: {
                                twitter_handle: 'schmoe',
                                github_profile_username: 'jschmoe'}
                               }
          expect(response).to be_redirect
          expect(joe.reload.twitter_handle).to eq 'schmoe'
          expect(joe.github_profile_username).to eq 'jschmoe'
        end
      end
    end
  end
end
