
FactoryGirl.define do

  factory :session do

    title "Stuff about things"
    description "whatever"
    participant { create :luke }
    association :event
    association :room

  end
end
