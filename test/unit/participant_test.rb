require 'test_helper'

class ParticipantTest < ActiveSupport::TestCase
  context "restrict_after" do
    setup do
      @event = FactoryGirl.create(:event)
      @time1 = FactoryGirl.create(:timeslot_1, event: @event)
      @time2 = FactoryGirl.create(:timeslot_2, event: @event)
      @time3 = FactoryGirl.create(:timeslot_3, event: @event)

      puts "Time 1 is #{@time1.starts_at}"
    end
    should "not do anything if there are no timeslots that end after the given time" do
      assert_no_difference 'PresenterTimeslotRestriction.count' do

        FactoryGirl.create(:luke).restrict_after(Time.zone.parse("#{@event.date.strftime('%Y-%m-%d')} 15:00"))
      end
    end

    should "add a restriction for all timeslots that end after the given time" do
      p = FactoryGirl.create(:luke)
      p.restrict_after(Time.zone.parse("#{@event.date.strftime('%Y-%m-%d')} 08:00"))
      assert_equal Timeslot.count, p.presenter_timeslot_restrictions.count
    end

    should "not add restrictions if a timeslot ends before the given time" do
      p = FactoryGirl.create(:luke)
      # p.restrict_after(Time.zone.local(Date.today.year, Date.today.month, Date.today.day, 10, 30))
      p.restrict_after(Time.zone.parse("#{@event.date.strftime('%Y-%m-%d')} 10:30"))
      assert_equal [@time2, @time3], p.presenter_timeslot_restrictions.map(&:timeslot)
    end
  end
end
