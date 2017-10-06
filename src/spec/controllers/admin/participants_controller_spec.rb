# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Admin::ParticipantsController do
  let(:participant) do
    FactoryGirl.create(:participant, name: 'John McCarthy', email: 'parens@example.org')
  end

  describe '#index' do
    it 'should be successful' do
      get :index
      expect(response).to be_successful
      expect(assigns[:participants]).to eq [participant]
    end
  end

  describe '#edit' do
    it 'is successful' do
      get :edit, params: { id: participant }
      expect(response).to be_successful
      expect(assigns[:participant]).to eq participant
    end
  end

  describe '#update' do
    it 'is successful' do
      put :update, params: { id: participant, participant: {
        name: 'The father of LISP', email: 'g@example.org', bio: 'Functionally just another dude'
      } }
      expect(response).to redirect_to admin_participants_path
      expect(flash[:success]).to eq 'Participant updated.'
      expect(assigns[:participant]).to eq participant
      expect(assigns[:participant].name).to eq 'The father of LISP'
    end
  end

  describe '#new' do
    it 'is successful' do
      get :new
      expect(response).to be_successful
      expect(assigns[:participant]).to be_a Participant
    end
  end

  describe '#create' do
    it 'is successful' do
      expect {
        post :create, params: { participant: {
          name: 'The father of LISP', email: 'g@example.org', bio: 'Functionally just another dude'
        } }
      }.to change { Participant.count }.by(1)
      expect(response).to redirect_to admin_participants_path
      expect(flash[:success]).to eq 'Participant created.'
      expect(assigns[:participant].name).to eq 'The father of LISP'
    end
  end
end
