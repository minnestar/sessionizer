require File.dirname(__FILE__) + "/../../db/seeds"

today = Date.today

current_event = Event.fixie(:current_event,
                            :name => "Current Event",
                            :date => today)

Timeslot.fixie(:timeslot_1,
               :event => current_event,
               :starts_at => Time.zone.local(today.year, today.month, today.day, 9),
               :ends_at => Time.zone.local(today.year, today.month, today.day, 9, 50))

Timeslot.fixie(:timeslot_2,
               :event => current_event,
               :starts_at => Time.zone.local(today.year, today.month, today.day, 10),
               :ends_at => Time.zone.local(today.year, today.month, today.day, 10, 50))

Timeslot.fixie(:timeslot_3,
               :event => current_event,
               :starts_at => Time.zone.local(today.year, today.month, today.day, 11),
               :ends_at => Time.zone.local(today.year, today.month, today.day, 11, 50))

Room.fixie(:room,
           :event => current_event,
           :name => 'Only Room',
           :capacity => 100)

luke = Participant.fixie(:luke,
                         :email => "look@recursion.org",
                         :name => 'Luke Francl')

joe = Participant.fixie(:joe,
                        :email => "joe@example.com",
                        :name => "Joe Schmoe")

session = Session.fixie(:luke_session,
                        :event => current_event,
                        :title => "Stuff about things",
                        :description => "whatever",
                        :participant => luke)

session.categorizations.create!(:category => Category.first)

session.attendances.create(:participant => joe)
