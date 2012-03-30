class Event < ActiveRecord::Base
  has_many :sessions
  has_many :timeslots
  has_many :rooms
  
  validates_presence_of :name, :date

  def self.current_event
    @current_event ||= Event.last(:order => :date)
  end
end
