require File.dirname(__FILE__) + "/../../db/seeds"

current_event = Event.fixie(:current_event,
                            :name => "Current Event",
                            :date => Date.today)

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
