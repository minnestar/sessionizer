require 'test_helper'

class ParticipantTest < ActiveSupport::TestCase
  context "restrict_after" do 
    should "not do anything if there are no timeslots that end after the given time" do
      assert_no_difference 'PresenterTimeslotRestriction.count' do
        Fixie.participants(:luke).restrict_after(Time.zone.local(Date.today.year, Date.today.month, Date.today.day, 15))
      end
    end

    should "add a restriction for all timeslots that end after the given time" do
      p = Fixie.participants(:luke)
      p.restrict_after(Time.zone.local(Date.today.year, Date.today.month, Date.today.day, 8))
      assert_equal Timeslot.count, p.presenter_timeslot_restrictions.count
    end

    should "not add restrictions if a timeslot ends before the given time" do
      p = Fixie.participants(:luke)
      p.restrict_after(Time.zone.local(Date.today.year, Date.today.month, Date.today.day, 10, 30))
      assert_equal [Fixie.timeslots(:timeslot_2), Fixie.timeslots(:timeslot_3)], p.presenter_timeslot_restrictions.map(&:timeslot)
    end
  end
end
