require 'spec_helper'

RSpec.feature "Displaying the schedule" do
  let(:event) { create(:event, :full_event) }

  before do
    allow(Settings).to receive(:show_schedule?).and_return true
    create(:session, timeslot: event.timeslots.first, event: event)
  end

  scenario "drawing the schedule page" do
    visit '/schedule'

    expect(page).to have_content "Stuff about things"
  end
end
