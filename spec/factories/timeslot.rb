FactoryGirl.define do

  factory :timeslot do
    association :event

    starts_at { Time.zone.parse("#{event.date.to_s} #{generate(:slot_time)}") }
    ends_at { starts_at + @@session_length }
  end

end
