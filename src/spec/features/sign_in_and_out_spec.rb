require "spec_helper"

feature "Authentication and account creation things" do

  let(:user) { create(:participant) }

  scenario "As a user who doesn't have an account" do
    visit root_url

    click_link "Log in"

    fill_in 'Email', with: 'bob@example.com'
    fill_in 'Password', with: 'bobzurunkle!!!'
    click_button "Log in"

    expect(page).to have_content "Sorry, couldn't find that participant. Try again, or sign up to register a new account."
  end

  scenario "As a user with an account, I want to sign in and out" do
    visit root_path

    click_link "Log in"

    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    check 'Remember me'
    click_button "Log in"

    expect(page).to have_content "You're logged in. Welcome back."

    click_link "Log out"

    expect(page).to have_content "You have been logged out."
  end

  scenario "As a user I can register a new account" do
    visit root_path

    click_link "Log in"
    click_link 'Register here'

    name = FFaker::Name.name
    fill_in 'Your name*', with: name 
    fill_in 'Your email', with: FFaker::Internet.safe_email 
    fill_in 'Password*',  with: "anything, it doesnt matter" 
    click_button "Create Participant"

    expect(page).to have_content "Thanks for registering an account. You may now create sessions and mark sessions you'd like to attend" 
    expect(page).to have_content "Welcome #{name}"
  end

  scenario "As a user I try to register a new account with an already taken email address" do
    visit root_path

    click_link "Log in"
    click_link 'Register here'

    name = FFaker::Name.name
    fill_in 'Your name*', with: user.name
    fill_in 'Your email', with: user.email
    fill_in 'Password', with: "anything, it doesnt matter" 
    click_button "Create Participant"

    expect(page).to have_content "There was a problem creating that account."
    within("#participant_email_input") do
      expect(page).to have_content "has already been taken"
    end
  end
end
