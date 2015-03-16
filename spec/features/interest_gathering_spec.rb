require "spec_helper"

feature "Gauging interest in a session" do
  let(:event) { create(:event, :full_event) }
  background do
    create(:session, title: "A neat talk", event: event)
  end

  scenario "As a guest, I want to express my interest", js: true do
    visit root_path

    click_link "A neat talk"
    click_link "Yes! I might attend."

    fill_in "Name", with: "Dennis Ritchie"
    fill_in "Email", with: "c-lang@example.org"
    fill_in "Password", with: "c4ever!"
    click_button "Register"

    expect(page).to have_content 'Thanks for your interest in this session.'
    expect(page).to have_selector '#participants li', text: 'Dennis Ritchie'
  end


  let(:user) { create(:participant, name: 'Hedy Lamarr', email: 'freq-hopper@example.org') }

  scenario "As a signed in user I want to express my interest", js: true do
    visit root_path

    click_link "Log in"

    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button "Log in"

    click_link "A neat talk"
    click_link "Yes! I might attend."

    expect(page).to have_content 'Thanks for your interest in this session.'
    expect(page).to have_selector '#participants li', text: 'Hedy Lamarr'
  end
end

