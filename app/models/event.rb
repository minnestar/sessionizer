class Event < ActiveRecord::Base
  has_many :sessions, dependent: :destroy
  has_many :timeslots, dependent: :destroy
  has_many :rooms, dependent: :destroy

  has_many :presenter_timeslot_restrictions, :through => :timeslots
  has_many :code_of_conduct_agreements, dependent: :destroy

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

  def create_default_timeslots
    if timeslots.any?
      raise "#{name} (event.id=#{id}) already has timeslots; please delete them before running this task"
    end

    session_num = 0
    session_length = nil

    Timeslot.transaction do
      Settings.default_timeslot_config.each do |conf|
        timeslot = timeslots.new
        timeslot.starts_at = Time.zone.parse("#{date.to_s} #{conf[:start]}")
        timeslot.ends_at = Time.zone.parse("#{date.to_s} #{conf[:end]}")

        if special_title = conf[:special]
          timeslot.title = special_title
          timeslot.schedulable = false
        else
          session_num += 1
          timeslot.title = "Session #{session_num}"
          timeslot.schedulable = true

          this_session_length = timeslot.ends_at - timeslot.starts_at
          session_length ||= this_session_length
          if session_length != this_session_length
            Rails.logger.warn "WARNING: #{timeslot.title} is a different length from previous sessions"
          end
        end

        timeslot.save!
      end
    end
  end
end
