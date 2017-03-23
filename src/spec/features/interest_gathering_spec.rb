require "spec_helper"

feature "Gauging interest in a session" do

  let(:event) { create(:event, :full_event) }
  let(:user) { create(:participant, name: 'Hedy Lamarr', email: 'freq-hopper@example.org') }

  background do
    create(:session, title: "A neat talk", event: event)
    visit root_path
  end

  scenario "As a guest, I want to express my interest", js: true do

    click_link "A neat talk", match: :first
    page.find("#attend").click

    fill_in "Name", with: "Dennis Ritchie"
    fill_in "Email", with: "c-lang@example.org"
    fill_in "Password", with: "c4ever!!!!!!!!!"
    click_button "Register"

    expect(page).to have_content 'Thanks for your interest in this session.'
    expect(page).to have_selector 'ul#participants li', text: 'Dennis Ritchie'
  end


  scenario "As a signed in user I want to express my interest", js: true do
    sign_in_user user

    click_link "A neat talk", match: :first
    page.find("#attend").click

    expect(page).to have_content 'Thanks for your interest in this session.'
    expect(page).to have_selector 'ul#participants li', text: 'You!'
  end

end

