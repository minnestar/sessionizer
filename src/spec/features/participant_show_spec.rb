require "spec_helper"

feature 'View participant profile' do
  context 'With an authenticated user' do 
    let(:luke) { create(:luke) }

    scenario 'Can view participant profile when there are no events or sessions' do
      visit participant_path(luke)
      expect(page).to have_selector('h1', text: 'Luke Francl')
      expect(page).to have_content 'the man with the master plan'
      expect(page).to have_content "This person isn't presenting any sessions."
      expect(page).to have_content "This person hasn't expressed interested in any sessions yet."
    end
  end
end
