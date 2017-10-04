
FactoryGirl.define do
  factory :session do
    title 'Stuff about things'
    description 'whatever'
    participant
    association :event
    association :room
  end
end
