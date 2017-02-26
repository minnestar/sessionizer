require 'spec_helper'

describe Admin::SessionsController do
  before do
    activate_authlogic
    ParticipantSession.create(user)
  end

  let(:event) { create(:event) }
  let(:user) { create(:participant) }

  context "with an existing session" do
    let!(:session) { create(:session, event: event) }

    describe "index" do
      it "should set the sessions" do
        get :index
        expect(response).to be_successful
        expect(assigns[:sessions]).to eq [session]
      end
    end

    describe "update" do
      let(:category) { Category.last }

      it "should be updatable" do
        patch :update, params: { id: session, session: { title: 'new title', description: 'new description', category_ids: [category.id], level_id: '2' } }
        expect(response).to redirect_to admin_sessions_path
        expect(assigns[:session].title).to eq 'new title'
      end
    end

    describe "edit" do
      it "should be successful" do
        get :edit, params: {id: session}
        expect(response).to be_successful
      end
    end
  end

  describe "create" do
    let!(:event) { create(:event) }
    let(:category) { Category.last }
    before do
      Participant.destroy_all
      create(:participant, name: "Joe Schmoe")
    end

    context "with valid values" do
      it "creates a new session " do

        expect {
          expect {
            post :create, params: { session: { title: 'new title', description: 'new description', category_ids: [category.id], level_id: '2', name: "Ada Lovelace"} }
          }.to change { Session.count }.by(1)
        }.to change { Participant.count }.by(1)
        expect(response).to redirect_to admin_sessions_path
        expect(assigns[:session].title).to eq 'new title'
        expect(assigns[:session].participant.name).to eq 'Ada Lovelace'
        expect(assigns[:session].event).to eq event
        expect(assigns[:session].category_ids).to include category.id
        expect(flash[:notice]).to eq "Presentation added"
      end
    end

    context "with invalid values" do
      it "shows the errors" do

        expect {
          post :create, params: { session: { title: ''} }
        }.not_to change { Session.count }
        expect(response).to render_template('new')
      end
    end
  end

  describe "new" do
    it "should be successful" do
      get :new
      expect(response).to be_successful
      expect(assigns[:session]).to be_kind_of Session
    end
  end
end

