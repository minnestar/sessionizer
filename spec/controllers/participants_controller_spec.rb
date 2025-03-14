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
      expect(flash[:notice]).to eq "Thanks for registering an account. Please check your email to confirm your account."
    end

    it "should not be successful if a bot provides contact_details field" do
      expect{
        post :create, params: { participant: { name: 'spam bot', 
                                               email: 'spambot@example.org', 
                                               password: 'spam-bot',
                                               contact_details: 'this is a honeypot field that i fell for because im a spam bot'
                              }
        }
      }.not_to change(Participant, :count)
      expect(response).to render_template(:new)
      expect(flash[:error]).to eq "There was a problem creating your account."
    end
  end

  describe "#show" do
    it "should be successful" do
      get :show, params: {id: participant}
      expect(response).to be_successful
      expect(assigns(:participant)).to be_kind_of Participant
    end

    context "when logged in" do
      context "when logged in user has not confirmed email" do
        let(:unconfirmed_email_participant) { create(:participant, email_confirmed_at: nil )}

        before do
          activate_authlogic
          ParticipantSession.create(unconfirmed_email_participant)
        end

        it "should display confirm email flash message" do
          get :show, params: {id: participant}
          expect(flash[:alert]).to be_present
        end
      end
    end

    context "when logged in user has confirmed email" do
      let(:unconfirmed_email_participant) { create(:participant, email_confirmed_at: Time.now )}
        
      before do
        activate_authlogic
        ParticipantSession.create(unconfirmed_email_participant)
      end

      it "should not display confirm email flash message" do
        get :show, params: {id: participant}
        expect(flash[:alert]).not_to be_present
      end
    end


    context "when not logged in" do
      it "should not show confirm email flash message" do
        get :show, params: {id: participant}
        expect(flash[:alert]).not_to be_present
      end
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
        expect(response).to redirect_to participant_path(joe)
        expect(joe.reload.name).to eq 'schmoe, joe'
      end

      describe "more attributes are not required" do
        it "should be successful" do
          put :update, params: {
            id: joe, participant: { bio: 'schmoe' }
          }
          expect(response).to be_redirect
          expect(joe.reload.bio).to eq 'schmoe'
        end
      end

      describe "when email address is changed" do
        it "should unconfirm the user's email" do
          put :update, params: {id: joe, participant: { email: 'new@example.org',}}
          expect(response).to be_redirect
          expect(joe.reload.email_confirmed_at).to be_nil
        end
      end
    end
  end
end
