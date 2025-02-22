require "spec_helper"

feature "Manage a user profile" do

  context "As an authenticated user" do
    let(:joe) { create(:joe, email_confirmed_at: Time.now) }
    background do
      create(:event)
      sign_in_user(joe)
      expect(page).to have_content "You're logged in. Welcome back."
    end

    scenario "I can update my profile attributes" do
      click_link "Welcome Joe Schmoe"
      fill_in 'Your GitHub username', with: "JoeSchmoeGithubUsername"
      fill_in 'Your Twitter handle', with: "JoeSchmoeTwitterHandle"
      bio = FFaker::HipsterIpsum.paragraph(3)
      fill_in 'Bio',  with: bio
      click_button "Update Profile"

      expect(page).to have_content "JoeSchmoeGithubUsername"
      expect(page).to have_content "JoeSchmoeTwitterHandle"
      expect(page).to have_content bio
    end
  end

end

