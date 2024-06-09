
FactoryBot.define do
  factory :session do
    sequence :title do |n|
      " Session #{n}"
    end
    description { 'whatever' }
    participant
    association :event
    association :room
  end
end
