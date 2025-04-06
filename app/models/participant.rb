class Participant < ActiveRecord::Base
  has_many :sessions
  has_many :attendances, dependent: :destroy
  has_many :sessions_attending, :through => :attendances, :source => :session
  has_many :presentations
  has_many :sessions_presenting, :through => :presentations, :source => :session
  has_many :presenter_timeslot_restrictions, dependent: :destroy
  has_many :code_of_conduct_agreements, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true
  validates_uniqueness_of :email, :case_sensitive => false
  validates :password, presence: true, on: :create
  validate :bio_does_not_include_example_links

  # used for formtastic form to allow sending a field related to a separate model
  attr_accessor :code_of_conduct_agreement
  
  # fake form field that acts as a honeypot for preventing spam. 
  attr_accessor :contact_details
  validates_absence_of :contact_details

  acts_as_authentic do |config|
    config.crypto_provider = Authlogic::CryptoProviders::BCrypt
    config.require_password_confirmation = false
  end

  scope :confirmed, -> { where.not(email_confirmed_at: nil) }
  scope :with_sessions, -> { joins(:sessions) }

  def self.ransackable_attributes(auth_object = nil)
    ["name", "email", "bio", "email_confirmed_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end

  def restrict_after(datetime, weight=1, event=Event.current_event)
    event.timeslots.each do |timeslot|
      if timeslot.ends_at > datetime
        self.presenter_timeslot_restrictions.create!(
          timeslot: timeslot,
          weight:   weight)
      end
    end
  end

  def restrict_before(datetime, weight=1, event=Event.current_event)
    event.timeslots.each do |timeslot|
      if timeslot.starts_at < datetime
        self.presenter_timeslot_restrictions.create!(
          timeslot: timeslot,
          weight:   weight)
      end
    end
  end

  def restrict_not_at(datetime, weight=1, event=Event.current_event)
    event.timeslots.each do |timeslot|
      if timeslot.ends_at < datetime || timeslot.starts_at > datetime
        self.presenter_timeslot_restrictions.create!(
          timeslot: timeslot,
          weight:   weight)
      end
    end
  end

  def restrict_to_only(allowed_slots, weight=1, event=Event.current_event)
    event.timeslots.each do |timeslot|
      unless allowed_slots.include?(timeslot)
        self.presenter_timeslot_restrictions.create!(
          timeslot: timeslot,
          weight:   weight)
      end
    end
  end

  def deliver_password_reset_instructions!
    reset_perishable_token!
    Notifier.password_reset_instructions(self).deliver_now!
  end

  def signed_code_of_conduct_for_current_event?
    return false unless Event.current_event

    CodeOfConductAgreement.where({
      participant_id: id,
      event_id: Event.current_event.id,
    }).exists?
  end

  def attending_session?(session)
    sessions_attending.include?(session)
  end

  def self.find_by_case_insensitive_email(email)
    where(['lower(email) = ?', email.to_s.downcase]).first
  end

  def email_confirmed?
    !!self.email_confirmed_at
  end

  def deliver_email_confirmation_instructions!
    reset_perishable_token!
    Notifier.participant_email_confirmation(self).deliver_now!
  end

private

  def bio_does_not_include_example_links
    if bio&.include?("example.com")
      errors.add(:bio, "please remove sample links to “example.com”")
    end
  end
end
