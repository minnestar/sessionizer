FactoryBot.define do
  factory :session do
    sequence :title do |n|
      "Session #{n}"
    end
    description { 'whatever' }
    participant
    association :event

    # ensure room is associated with the same event as the session
    after(:build) do |session|
      session.room = session.event.rooms.first || create(:room, event: session.event)
    end
  end
end
