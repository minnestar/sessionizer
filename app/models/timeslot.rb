class Timeslot < ActiveRecord::Base
  belongs_to :event
  has_many :sessions, dependent: :nullify
  has_many :presenter_timeslot_restrictions, dependent: :destroy

  validates :starts_at, :presence => true
  validates :ends_at, :presence => true
  validates :event_id, :presence => true

  default_scope { order 'starts_at asc' }

  def to_s
    "#{starts_at.in_time_zone.to_s(:hhmm)} - #{ends_at.in_time_zone.to_s(:hhmm)}"
  end
end
