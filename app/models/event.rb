class Event < ActiveRecord::Base
  has_many :sessions, dependent: :destroy
  has_many :timeslots, dependent: :destroy
  has_many :rooms, dependent: :destroy

  has_many :presenter_timeslot_restrictions, :through => :timeslots

  validates_presence_of :name, :date
  attr_accessible :name, :date

  def self.current_event(opts = {})
    @current_event ||= Event.last(opts.reverse_merge(:order => :date))
  end
end
