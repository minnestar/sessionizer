module AuthenticationSupport

  def sign_in_user(user)
    
    visit home_page_path

    click_link "Log in"

    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button "Log in"

    expect(page).to have_content "You're logged in. Welcome back."

  end

  def sign_in_new_user
    user = create(:participant)
    sign_in_user(user)
  end

end

