FactoryGirl.define do

  factory :presenter_timeslot_restriction do
    association :participant
    association :timeslot
    weight 1
  end
end
