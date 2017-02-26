require 'spec_helper'

describe EventsController do
  let(:event) { FactoryGirl.create(:event) }

  context 'show' do
    context 'in JSON format' do
      it 'is successful' do
        get :show, params: {id: event, format: :json}
        expect(response).to be_success
        expect(response.content_type).to eq('application/json')
      end
    end
  end
end
