
FactoryGirl.define do

  factory :room do
    association :event
    name { generate :room_name }
    capacity [100, 250, 60, 40, 24].sample
  end

end
