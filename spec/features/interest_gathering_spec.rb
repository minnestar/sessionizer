require "spec_helper"

feature "Gauging interest in a session" do

  let(:event) { create(:event, :full_event) }
  let(:confirmed_user) { create(:participant, name: 'Hedy Lamarr', email: 'freq-hopper@example.org', email_confirmed_at: Time.now) }
  let(:unconfirmed_user) { create(:participant, email_confirmed_at: nil) }

  background do
    create(:session, title: "A neat talk", event: event)
    visit root_path
  end

  scenario "As a guest, I want to express my interest", js: true, unless: ENV['CI'] do

    click_link "A neat talk", match: :first
    page.find("#attend").click

    fill_in "Name", with: "Dennis Ritchie"
    fill_in "Email", with: "c-lang@example.org"
    fill_in "Password", with: "c4ever!!!!!!!!!"
    click_button "Create Account"

    expect(page).to have_content 'Thanks for your interest in this session. Please check your email to confirm your account.'
    expect(page).to have_content 'No participants yet'
  end

  scenario "As a signed in unconfirmed user I want to express my interest", js: true, unless: ENV['CI'] do
    sign_in_user unconfirmed_user

    click_link "A neat talk", match: :first
    page.find("#attend").click

    expect(page).to have_content 'Thanks for your interest in this session.'
    expect(page).to have_content 'No participants yet'
  end

  scenario "As a signed in confirmed user I want to express my interest", js: true, unless: ENV['CI'] do
    sign_in_user confirmed_user

    click_link "A neat talk", match: :first
    page.find("#attend").click

    expect(page).to have_content 'Thanks for your interest in this session.'
    expect(page).to have_selector 'ul#participants li', text: 'You!'
  end

end

