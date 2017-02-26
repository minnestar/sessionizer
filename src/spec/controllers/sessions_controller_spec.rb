require 'spec_helper'

describe SessionsController do
  before do
    activate_authlogic
    ParticipantSession.create(user)
  end

  let(:user) { create(:participant) }
  let(:event) { create(:event) }

  context "with an existing session" do
    let!(:session) { create(:session, event: event) }

    describe "update" do
      it "is not updatable by someone who doesn't own it" do
        patch :update, params: { id: session, session: { description: 'Lulz' } }
        expect(response).to redirect_to session
      end

      context "when the owner is signed in" do

        let(:user) { session.participant }

        let(:category) { Category.last }

        it "should be updatable" do
          patch :update, params: { id: session, session: { title: 'new title', description: 'new description', category_ids: [category.id], level_id: '2' } }
          expect(response).to redirect_to session
          expect(assigns[:session].title).to eq 'new title'
        end
      end
    end

    describe "edit" do
      it "should not be editable by someone who doesn't own it" do
        get :edit, params: {id: session}
        expect(response).to redirect_to session
      end
    end

    describe "export" do
      it "should be successful" do
        get :export
        expect(response).to be_successful
        expect(assigns[:sessions]).to eq [session]
      end
    end
    describe "popularity" do
      it "should be successful" do
        get :popularity
        expect(response).to be_successful
        expect(assigns[:sessions]).to eq [session]
      end
    end

    describe "index" do
      it "should be successful" do
        get :index
        expect(response).to be_successful
        expect(assigns[:sessions]).to eq [session]
      end

      context "with JSON format" do
        it "is successful and have all the things" do
          get :index, format: :json
          expect(response).to be_successful
          expect(response.content_type).to eq('application/json')
          expect(response.body).to eq SessionsJsonBuilder.new.to_json([session])
        end
      end

      describe "when there are multiple events" do
        let!(:event2) { create :event }
        let!(:joe) { create :joe }
        let!(:session2) { create(:session, event: event2, participant: joe) }
        before do
          Settings.instance.update_attribute(:current_event_id, event.id)
        end

        it "should allow exporting previous events" do
          get :index, params: { event_id: event2.id }
          expect(response).to be_successful
          expect(assigns[:sessions]).to eq [session2]

          get :index, params: { event_id: event.id }
          expect(response).to be_successful
          expect(assigns[:sessions]).to eq [session]
        end
      end
    end
  end

  describe "create" do
    let!(:event) { create(:event) }
    let(:category) { Category.last }

    context "with valid values" do
      it "creates a new session " do

        expect {
          post :create, params: { session: { title: 'new title', description: 'new description', category_ids: [category.id], level_id: '2' } }
        }.to change { Session.count }.by(1)
        expect(response).to redirect_to assigns[:session]
        expect(assigns[:session].title).to eq 'new title'
        expect(assigns[:session].participant).to eq user
        expect(assigns[:session].event).to eq event
        expect(assigns[:session].category_ids).to include category.id
        expect(flash[:notice]).to eq "Thanks for adding your session."
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
end
