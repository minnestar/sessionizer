FactoryBot.define do

  factory :event do
    sequence :name do |n|
      "Minnebar #{n}"
    end
    date { 30.days.since }
    venue { "Best Buy HQ" }
    start_time { date.in_time_zone.change(hour: 8, min: 0) }
    end_time { date.in_time_zone.change(hour: 18, min: 30) }

    trait :full_event do
      transient do
        rooms_count { 9 }
        timeslots_count { 7 }
      end

      after(:create) do |event, evaluator|
        create_list(:room, evaluator.rooms_count, event: event)
        create_list(:timeslot, evaluator.timeslots_count, event: event)
      end
    end
  end

end
