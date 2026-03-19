FactoryBot.define do
  factory :event_category do
    event
    category
    sequence(:position) { |n| n }
  end
end
