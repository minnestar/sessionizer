module AuthenticationSupport

  def sign_in_user(user)
    
    visit home_page_path

    click_link "Log in"

    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button "Log in"

    expected_message = user.email_confirmed? ?
      "You're logged in. Welcome back." :
      "Your email has not been confirmed. Please Confirm your email."
    expect(page).to have_content expected_message

  end

  def sign_in_new_user
    user = create(:participant)
    sign_in_user(user)
  end

end

