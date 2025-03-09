require 'spec_helper'

describe Admin::Legacy::PresentersController do

  let(:presenter) { FactoryBot.create(:participant, name: 'John McCarthy', email: 'parens@example.org') }
  let(:event) { FactoryBot.create(:event) }
  let!(:session) { FactoryBot.create(:session, participant: presenter, event: event) }

  describe "#index" do
    it "should be successful" do
      get :index
      expect(response).to be_successful
      expect(assigns[:presenters]).to eq [presenter]
    end
  end

  describe "#edit" do
    it "should be successful" do
      get :edit, params: {id: presenter}
      expect(response).to be_successful
      expect(assigns[:presenter]).to eq presenter
    end
  end

  describe "#update" do
    it "should be successful" do
      put :update, params: {id: presenter, participant: {
                                  name: 'The father of LISP', email: 'g@example.org', bio: "Functionally just another dude"
                                }
                            }
      expect(response).to redirect_to admin_legacy_presenters_path
      expect(flash[:success]).to eq "Presenter updated."
      expect(assigns[:presenter]).to eq presenter
      expect(assigns[:presenter].name).to eq 'The father of LISP'
    end
  end

  describe "#export" do
    it "should be successful" do
      get :export
      expect(response.body).to eq "\"John McCarthy\" <parens@example.org>"
    end
  end

  describe "#export_all" do
    let(:older_event) { FactoryBot.create(:event, date: 1.year.ago) }
    let(:second_presenter) { FactoryBot.create(:participant, name: 'Kristen Nygaard', email: 'objectify@example.org') }
    let!(:second_session) { FactoryBot.create(:session, participant: second_presenter, event: older_event) }

    it "should be successful" do
      get :export_all
      expect(response.body).to eq "\"John McCarthy\" <parens@example.org>,\n\"Kristen Nygaard\" <objectify@example.org>"
    end
  end
end
