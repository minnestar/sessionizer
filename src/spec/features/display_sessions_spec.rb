require "spec_helper"

feature "View sessions" do
  scenario "when no event exists" do
    visit root_path
    expect(page).to have_content 'No event is being held right now'
  end

  context "when an event is setup" do
    background do
      create(:event, :full_event)
    end
    scenario "it shows the sessions" do
      visit root_path
      expect(page).to have_content 'Sessions about Development'
    end
  end
end

