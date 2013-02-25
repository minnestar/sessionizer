Given /^an upcoming event/ do
  Event.create({name:'Minnebar', date:(Date.today+30.days)})
  session_length = 45.minutes

  event = Event.current_event

  ['Design', 'Development', 'Hardware', 'Startups', 'Other'].each_with_index do |c, idx|
    Category.create(id:idx, name:c) 
  end

  ["09:40", "10:40", "11:40", "13:50", "14:50", "15:50", "16:50"].each do |st|
    starts = Time.zone.parse("#{event.date.to_s} #{st}")
    event.timeslots.create!(:starts_at => starts, :ends_at => starts + session_length)
  end

  [{ :name => 'Harriet', :capacity => 100 },
   { :name => 'Calhoun', :capacity => 100 },
   { :name => 'Nokomis', :capacity => 100 },
   { :name => 'Minnetonka', :capacity => 100 },
   { :name => 'Theater', :capacity => 250 },
   { :name => 'Proverb-Edison', :capacity => 60 },
   { :name => 'Landers', :capacity => 40 },
   { :name => 'Learn', :capacity => 24 },
   { :name => 'Challenge', :capacity => 24 }
  ].each do |room|
    event.rooms.create!(room)
  end
end

Given /^I browse the sessions$/ do
  visit root_path
  #save_and_open_page
end


Given /^I add a new Development session about RoR$/ do
  #save_and_open_page
  click_link("Add session")
  fill_in('Title', with: 'Rails 4 FTW')
  fill_in('Description', with: 'Rails Desc')
  fill_in('Your Name', with: 'Jack Johnson')
  fill_in('Your Email', with: 'jack@example.com')
  #choose('Categories', with: [])
 
  click_button 'Create Session'
end


Then /^the new session should show up in the session list$/ do
  pending # express the regexp above with the code you wish you had
end

When /^I indicate that I might attend a session$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I should be added to the participant list of that session$/ do
  pending # express the regexp above with the code you wish you had
end

