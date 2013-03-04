
@@categories = ['Design', 'Development', 'Hardware', 'Startups', 'Other']
@@rooms = [
  { :name => 'Harriet', :capacity => 100 },
  { :name => 'Calhoun', :capacity => 100 },
  { :name => 'Nokomis', :capacity => 100 },
  { :name => 'Minnetonka', :capacity => 100 },
  { :name => 'Theater', :capacity => 250 },
  { :name => 'Proverb-Edison', :capacity => 60 },
  { :name => 'Landers', :capacity => 40 },
  { :name => 'Learn', :capacity => 24 },
  { :name => 'Challenge', :capacity => 24 }
]
@@slots = ["09:40", "10:40", "11:40", "13:50", "14:50", "15:50", "16:50"]
@@session_length = 45.minutes


FactoryGirl.define do

  sequence :category_name do |n|
    @@categories[n % @@categories.length]
  end


  sequence :room_name do |n|
    @@rooms[ n % @@rooms.length][:name]
  end

  sequence :slot_time do |n|
    @@slots[n % @@slots.length]
  end
end
