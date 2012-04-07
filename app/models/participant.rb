class Participant < ActiveRecord::Base
  has_many :sessions
  has_many :attendances
  has_many :sessions_attending, :through => :attendances, :source => :session
  has_many :presentations
  has_many :sessions_presenting, :through => :presentations, :source => :session
  has_many :presenter_timeslot_restrictions

  validates_presence_of :name
  validates_uniqueness_of :email, :case_sensitive => false, :allow_blank => true

  def restrict_after(datetime, weight=1)
    Event.current_event.timeslots.each do |timeslot|
      if timeslot.ends_at >= datetime
        self.presenter_timeslot_restrictions.create!(:timeslot => timeslot, :weight => weight)
      end
    end
  end

  def restrict_before(datetime, weight=1)
    Event.current_event.timeslots.each do |timeslot|
      if timeslot.starts_at <= datetime
        self.presenter_timeslot_restrictions.create!(:timeslot => timeslot, :weight => weight)
      end
    end
  end
end
