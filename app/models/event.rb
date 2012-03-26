class Event < ActiveRecord::Base
  has_many :sessions
  has_many :timeslots

  validates_presence_of :name, :date

  def self.current_event
    @current_event ||= Event.first(:order => 'date desc')
  end
end
