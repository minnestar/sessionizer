FactoryGirl.define do

  factory :event do

    name "Minnebar"
    date 30.days.since

    trait :full_event do
      transient do
        rooms_count 9
        timeslots_count 7
      end

      after(:create) do |event, evaluator|
        create_list(:room, evaluator.rooms_count, event: event)
        create_list(:timeslot, evaluator.timeslots_count, event: event)
      end
    end
  end

end
