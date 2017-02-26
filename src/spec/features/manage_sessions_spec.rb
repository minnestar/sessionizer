require "spec_helper"

feature "Manage Sessions" do
  background do
    create(:event, :full_event)
  end

  scenario "As a guest, I want to register " do
    visit root_path

    all(".add-sessions-button").first.click
    click_link "Register here"

    fill_in 'participant_name', with: 'Jack Johnson'
    fill_in 'Your email', with: 'jack@example.com'
    fill_in 'Password', with: 's00persekret12345'
    click_button "Create Participant"

    all(".add-sessions-button").first.click

    fill_in('Title', with: 'Rails 4 FTW')
    fill_in('Description', with: 'Rails Desc')

    click_button 'Create Session'
    expect(page).to have_content 'Thanks for adding your session.'
  end
end
