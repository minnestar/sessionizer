require "spec_helper"

feature 'View participant profile' do
  context 'With an authenticated user' do 
    background do
      create(:event, :full_event)
    end
    let(:luke) { create(:luke) }

    scenario 'Can view participant profile when there are no sessions' do
      visit participant_path(luke)
      expect(page).to have_selector('h1', text: 'Luke Francl')
      expect(page).to have_content 'the man with the master plan'
      expect(page).to have_content "This person isn't presenting any sessions."
      expect(page).to have_content "This person hasn't expressed interest in any sessions yet."
    end
  end
end
