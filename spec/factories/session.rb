
FactoryGirl.define do

  factory :session do

    title "Stuff about things"
    description "whatever"
    participant { FactoryGirl.create :luke }
    association :event

  end
end
