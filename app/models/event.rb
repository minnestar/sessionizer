class Event < ActiveRecord::Base
  has_many :sessions
  has_many :timeslots
  has_many :rooms
  has_many :presenter_timeslot_restrictions, :through => :timeslots
  
  validates_presence_of :name, :date

  def self.current_event(opts = {})
    @current_event ||= Event.last(opts.reverse_merge(:order => :date))
  end
end
