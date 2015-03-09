class Event < ActiveRecord::Base
  has_many :sessions, dependent: :destroy
  has_many :timeslots, dependent: :destroy
  has_many :rooms, dependent: :destroy

  has_many :presenter_timeslot_restrictions, :through => :timeslots

  validates_presence_of :name, :date

  after_create :reset_current

  def self.current_event(opts = {})
    @current_event ||= begin
                         rel = Event.order(:date)
                         rel = rel.includes(opts[:include]) if opts[:include]
                         rel.last
                       end
  end

  def self.reset_current!
    @current_event = nil
  end

  def reset_current
    self.class.reset_current!
  end
end
