require "spec_helper"

feature "Manage Sessions" do
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
    click_button "Log in"

    expect(page).to have_content "You're logged in. Welcome back."

    click_link "Log out"

    expect(page).to have_content "You have been logged out."
  end
end

