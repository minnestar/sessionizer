
require "spec_helper"

feature "Register Accounts" do
  background do
    create(:event, :full_event)
  end

  scenario "As a guest, I want to register so that I can do things" do
    visit root_url

    click_link("Button-add-session")
    save_and_open_page

    click_link('Register here')
    save_and_open_page

  end

end

