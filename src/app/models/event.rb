class Event < ActiveRecord::Base
  has_many :sessions, dependent: :destroy
  has_many :timeslots, dependent: :destroy
  has_many :rooms, dependent: :destroy

  has_many :presenter_timeslot_restrictions, :through => :timeslots

  # Careful! Large joins here; use with caution:
  has_many :attendances, through: :sessions
  has_many :participants, through: :attendances

  validates_presence_of :name, :date

  def self.current_event
    self.order(:date).last
  end

  def current?
    if @current.nil?
      @current = self == Event.current_event
    end
    @current
  end

  def multiday?
    if @multiday.nil?
      separate_day_count = timeslots.map(&:starts_at).map(&:midnight).uniq.count
      @multiday = separate_day_count > 1
    end
    @multiday
  end

  # The list of timeslots that are at the first of each day of the event
  def first_timeslots_of_day
    @first_timeslots_of_day ||= begin
      timeslots
        .group_by { |slot| slot.starts_at.midnight }
        .map { |date, slots| slots.sort_by(&:starts_at).first }
        .sort_by(&:starts_at)
    end
  end
end
