require "spec_helper"

feature "Manage Sessions" do
  background do
    create(:event, :full_event)
  end

  scenario "As a new user, I want to register and add a session" do
    visit root_path

    click_link "Add Session", match: :first
    click_link "Register here"

    fill_in 'participant_name', with: 'Jack Johnson'
    fill_in 'Your email', with: 'jack@example.com'
    fill_in 'Password', with: 's00persekret12345'
    click_button "Create My Account"

    # Open the email confirmation link
    email = ActionMailer::Base.deliveries.last
    confirmation_link = email.body.match(/href="([^"]+)/)[1]
    visit confirmation_link

    visit root_path
    click_link "Add Session", match: :first

    fill_in('Title', with: 'Rails 4 FTW')
    fill_in('Description', with: 'Rails Desc')

    click_button 'Update Session'
    expect(page).to have_content 'Thanks for adding your session.'
  end

  scenario "As a user with an existing session, I see a warning when adding another" do
    event = Event.current_event
    user = create(:participant, email_confirmed_at: Time.current)
    create(:session, event: event, participant: user)

    sign_in_user(user)

    visit new_session_path
    expect(page).to have_content("already have a session for this event")
    expect(page).to have_content("encouraging presenters to submit just one session")
  end

  scenario "As a new user, I cannot add a session until my email has been confirmed" do
    visit root_path

    click_link "Add Session", match: :first
    click_link "Register here"

    fill_in 'participant_name', with: 'Jack Johnson'
    fill_in 'Your email', with: 'jack@example.com'
    fill_in 'Password', with: 's00persekret12345'
    click_button "Create My Account"

    click_link "Add Session", match: :first

    expect(page).to have_content(/email confirmation required/i)
    expect(page).to have_link("Send Confirmation Instructions")
    expect(page).not_to have_button("Update Session")
  end
end
