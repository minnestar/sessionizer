FactoryGirl.define do

  factory :timeslot do
    association :event

    starts_at { Time.zone.parse("#{event.date.strftime('%Y-%m-%d')} #{generate(:slot_time)}") }
    ends_at { starts_at + SESSION_LENGTH }

    factory :timeslot_1 do
      title 'Session 1'
      starts_at { Time.zone.parse("#{event.date.strftime('%Y-%m-%d')} 09:00:00") }

      ends_at { starts_at + 50.minutes }
    end

    factory :timeslot_2 do
      starts_at { Time.zone.parse("#{event.date.strftime('%Y-%m-%d')} 10:00:00") }
      ends_at { starts_at + 50.minutes}
    end

    factory :timeslot_3 do
      starts_at { Time.zone.parse("#{event.date.strftime('%Y-%m-%d')} 11:00:00") }
      ends_at { starts_at + 50.minutes }
    end

  end

end
