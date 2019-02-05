require 'spec_helper'

feature 'Password reset' do
  let(:user) { create(:participant, name: 'Hedy Lamarr', email: 'freq-hopper@example.org') }

  scenario 'The home page has a link to the reset password page' do
    visit root_path
    assert page.has_link?('Forgot Password?', href: new_password_reset_path)
  end

  scenario 'The reset password page has the expected content' do
    visit new_password_reset_path
    assert page.has_css?('h1', text: 'Reset Password')
    assert page.has_text?('Please enter your email address below')
  end

  scenario 'Participant can reset password' do
    # Event needed until Pull Request #202 is merged into the code base
    Event.create!(name: 'Event 1', date: Time.now)

    visit new_password_reset_path
    fill_in 'email', with: user.email
    click_button 'Reset Password'

    # Open and follow instructions
    open_email(user.email)
    assert current_email.subject.include?('Password Reset Instructions')
    assert current_email.body.include?('A request to reset your password has been made.')
    current_email.click_link 'Reset Password!'
    clear_emails

    # Provide new password
    assert page.has_css?('h1', text: 'Update your password')
    assert page.has_text?('Please enter the new password below')
    fill_in('password', with: 'MN Tech Community')
    sleep 4.1
    click_on 'Update Password'
    assert page.has_text?('Your password was successfully updated')
    click_on 'Log out'

    # Log in under the normal method
    visit root_path
    click_link "Log in"
    fill_in 'Email', with: user.email
    fill_in 'Password', with: 'MN Tech Community'
    check 'Remember me'
    click_button "Log in"
    expect(page).to have_content "You're logged in. Welcome back."
  end
end
