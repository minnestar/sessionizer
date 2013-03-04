FactoryGirl.define do

  factory :event do

    name "Minnebar"
    date 30.days.since

    trait :full_event do
      ignore do
        rooms_count 9
        timeslots_count 7
        categories_count 5
      end

      after(:create) do |event, evaluator|
        FactoryGirl.create_list(:category, evaluator.categories_count)
        FactoryGirl.create_list(:room, evaluator.rooms_count, event: event)
        FactoryGirl.create_list(:timeslot, evaluator.timeslots_count, event: event)
      end
    end
  end

end
