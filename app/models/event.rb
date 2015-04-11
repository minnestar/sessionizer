class Event < ActiveRecord::Base
  has_many :sessions, dependent: :destroy
  has_many :timeslots, dependent: :destroy
  has_many :rooms, dependent: :destroy

  has_many :presenter_timeslot_restrictions, :through => :timeslots

  # Careful! Large joins here; use with caution:
  has_many :attendances, through: :sessions
  has_many :participants, through: :attendances

  validates_presence_of :name, :date

  after_create :reset_current


  def self.current_event(opts = {})
    @current_event ||= begin
                         rel = Event.order(:date)
                         rel = rel.includes(opts[:include]) if opts[:include]
                         rel.last
                       end
  end


  # for future minnebars it would be great to have
  # timeslots that are 'unscheduable' as well as
  # a proper timeslot 'title' --clh
  def timeslots_with_lunch

    ts_with_title = self.timeslots.each_with_index do |t, idx|
      t.title = "Session #{idx + 1}"
      t
    end

    lunch = Timeslot.new(
      title: "Lunch",
      event_id: self.id,
      starts_at: "2015-04-11 12:15:00",
      ends_at: "2015-04-11 1:35:00",
    )

    ts_with_lunch = ts_with_title.insert(
      ts_with_title.size / 2,
      lunch
    )

    arrive = Timeslot.new(
      title: "Arrive/Breakfast",
      event_id: self.id,
      starts_at: "2015-04-11 8:00:00",
      ends_at: "2015-04-11 8:45:00",
    )
    session0 = Timeslot.new(
      title: "Session 0",
      event_id: self.id,
      starts_at: "2015-04-11 8:45:00",
      ends_at: "2015-04-11 9:05:00",
    )

    beer_me = Timeslot.new(
      title: "Beer Me!",
      event_id: self.id,
      starts_at: "2015-04-11 4:45:00",
      ends_at: "2015-04-11 7:00:00",
    )

    ts_with_lunch.insert( 0, session0 )
    ts_with_lunch.insert( 0, arrive )
    ts_with_lunch << beer_me
  end


  def self.reset_current!
    @current_event = nil
  end

  def reset_current
    self.class.reset_current!
  end
end
