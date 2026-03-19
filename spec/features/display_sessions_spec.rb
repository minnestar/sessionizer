require "spec_helper"

feature "View sessions" do
  scenario "when no event exists" do
    visit root_path
    expect(page).to have_content 'No event is being held right now'
  end

  context "when an event is setup" do
    let!(:event) { create(:event, :full_event) }

    scenario "it shows the sessions" do
      visit root_path
      expect(page).to have_content 'Sessions'
      expect(page).to have_link 'See more...'
    end
  end
end

