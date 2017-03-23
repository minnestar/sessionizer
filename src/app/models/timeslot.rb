class Timeslot < ActiveRecord::Base
  belongs_to :event
  has_many :sessions, dependent: :nullify
  has_many :presenter_timeslot_restrictions, dependent: :destroy

  validates :starts_at, :presence => true
  validates :ends_at, :presence => true
  validates :event_id, :presence => true

  default_scope { order 'starts_at asc' }

  def to_s(with_day: false)
    "#{date_range.to_s(with_day: with_day)} #{title}"
  end

  def date_range
    DateRange.new(starts_at, ends_at)
  end

  class DateRange
    attr_reader :start, :stop
    def initialize(start, stop)
      @start = start
      @stop = stop
    end

    def to_s(with_day: false)
      "#{start_day + ' ' if with_day}#{start_time} – #{end_time}"
    end

    def start_day
      start.in_time_zone.strftime('%a')
    end

    def start_time
      start.in_time_zone.to_s(:usahhmm)
    end

    def end_time
      stop.in_time_zone.to_s(:usahhmm)
    end
  end
end
