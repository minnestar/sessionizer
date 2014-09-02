require 'spec_helper'

feature "Displaying the schedule" do
  let(:event) { FactoryGirl.create(:event, :full_event) }

  before do
    FactoryGirl.create(:session, timeslot: event.timeslots.first, event: event)
  end

  scenario "should draw the schedule page" do
    visit '/schedule'
    expect(page).to have_content "Stuff about things"
  end
end
