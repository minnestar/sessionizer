require 'spec_helper'

describe Admin::Legacy::SessionsController do
  before do
    activate_authlogic
    ParticipantSession.create(user)
  end

  let(:event) { create(:event) }
  let(:user) { create(:participant) }

  context "with an existing session" do
    let!(:session) { create(:session, event: event) }

    describe '#index' do
      let(:slot_1) { create(:timeslot_1, event: event) }
      let(:slot_2) { create(:timeslot_2, event: event) }

      let!(:session3) { create(:session, event: event, timeslot: slot_2) }
      let!(:session2) { create(:session, event: event, timeslot: slot_1) }

      it 'sorts the sessions by timeslot start time' do
        get :index
        expect(response).to be_successful
        expect(assigns[:sessions]).to eq [session2, session3, session]
      end
    end

    describe "update" do
      let(:category) { Category.last }

      it "should be updatable" do
        patch :update, params: { id: session, session: { title: 'new title', description: 'new description', category_ids: [category.id], level_id: '2' } }
        expect(response).to redirect_to admin_legacy_sessions_path
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
end
