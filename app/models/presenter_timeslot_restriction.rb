class PresenterTimeslotRestriction < ActiveRecord::Base
  belongs_to :timeslot
  belongs_to :participant

  validates_presence_of :timeslot_id
  validates_presence_of :participant_id

  # The "weight" indicates how bad this time slot is for the presenter. A weight of 1 means that the present
  # absolutely cannot present at that time; the scheduler counts this the same as a presenter being double-booked
  # for the time slot. A weight of 0 means that the time slot is A-OK (the default), equivalent to the absence
  # of a record.
  validates_numericality_of :weight, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 1

  # attr_accessible :timeslot, :weight
end
