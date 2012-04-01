class Timeslot < ActiveRecord::Base
  belongs_to :event
  has_many :sessions, :dependent => :nullify
  has_many :presenter_timeslot_restrictions
  
  validates_presence_of :starts_at
  validates_presence_of :ends_at
  validates_presence_of :event_id

  default_scope :order => 'starts_at asc'

  def to_s
    "#{starts_at.to_s(:hhmm)} - #{ends_at.to_s(:hhmm)}"
  end
end
