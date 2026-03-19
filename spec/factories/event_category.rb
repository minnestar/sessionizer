FactoryBot.define do
  factory :event_category do
    association :event
    association :category
    sequence(:position) { |n| n }
  end
end
