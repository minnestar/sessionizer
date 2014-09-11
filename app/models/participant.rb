class Participant < ActiveRecord::Base
  has_many :sessions
  has_many :attendances
  has_many :sessions_attending, :through => :attendances, :source => :session
  has_many :presentations
  has_many :sessions_presenting, :through => :presentations, :source => :session
  has_many :presenter_timeslot_restrictions, dependent: :destroy

  validates_presence_of :name
  validates_uniqueness_of :email, :case_sensitive => false, :allow_blank => true

  acts_as_authentic do |config|
    config.crypto_provider = Authlogic::CryptoProviders::BCrypt
    config.require_password_confirmation = false
  end

  def restrict_after(datetime, weight=1, event=Event.current_event)
    event.timeslots.each do |timeslot|
      if timeslot.ends_at >= datetime
        self.presenter_timeslot_restrictions.create!(
          timeslot: timeslot,
          weight:   weight)
      end
    end
  end

  def restrict_before(datetime, weight=1, event=Event.current_event)
    event.timeslots.each do |timeslot|
      if timeslot.starts_at <= datetime
        self.presenter_timeslot_restrictions.create!(
          timeslot: timeslot,
          weight:   weight)
      end
    end
  end
end
