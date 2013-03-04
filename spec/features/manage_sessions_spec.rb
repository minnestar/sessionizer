require "spec_helper"

feature "Manage Sessions" do
  background do
    create(:event, :full_event)
  end

  scenario "As a guest, I want to register " do
    visit root_url

    click_link("Button-add-session")
    save_and_open_page




    #fill_in('Title', with: 'Rails 4 FTW')
    #fill_in('Description', with: 'Rails Desc')
    #fill_in('Your Name', with: 'Jack Johnson')
    #fill_in('Your Email', with: 'jack@example.com')
    #choose('Categories', with: [])
 
    #click_button 'Create Session'
    page.should have_content 'Success'
  end
end
