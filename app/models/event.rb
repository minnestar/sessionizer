class Event < ActiveRecord::Base
  class NotEnoughRoomsError < StandardError; end

  has_many :sessions, dependent: :destroy
  has_many :timeslots, dependent: :destroy
  has_many :rooms, dependent: :destroy

  has_many :event_categories, dependent: :destroy
  has_many :categories, through: :event_categories

  has_many :presenter_timeslot_restrictions, :through => :timeslots
  has_many :code_of_conduct_agreements, dependent: :destroy

  # Careful! Large joins here; use with caution:
  has_many :attendances, through: :sessions
  has_many :participants, through: :attendances

  validates_presence_of :name, :date

  after_create :create_default_categories

  def create_default_categories
    Category.create_defaults_for_event(self) if event_categories.empty?
  end

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

  def display_time
    return unless start_time && end_time

    "#{format_time(start_time)}-#{format_time(end_time)}"
  end

  def create_default_timeslots
    if timeslots.any?
      raise "#{name} (event.id=#{id}) already has timeslots; please delete them before running this task"
    end

    session_num = 0
    session_length = nil

    Timeslot.transaction do
      Settings.default_timeslots.each do |conf|
        timeslot = timeslots.new
        # Parse the time in the current time zone, then combine with the event date
        start_time = Time.zone.parse(conf["start"])
        end_time = Time.zone.parse(conf["end"])
        timeslot.starts_at = date.in_time_zone.change(hour: start_time.hour, min: start_time.min)
        timeslot.ends_at = date.in_time_zone.change(hour: end_time.hour, min: end_time.min)

        if special_title = conf["special"]
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

  def create_default_rooms(force: false)
    if rooms.any?
      if force
        rooms.destroy_all
      else
        raise "#{name} (event.id=#{id}) already has rooms; please delete them before running this task"
      end
    end

    Room.transaction do
      Settings.default_rooms.each do |conf|
        next if conf["active"] == false

        rooms.create!(
          name: conf["name"],
          capacity: conf["capacity"],
          schedulable: conf.fetch("schedulable", true)
        )
      end
    end
  end

  def assign_rooms!(reassign: false)
    log = []
    already_assigned_count = 0

    transaction_opts = Session.connection.open_transactions.zero? ? { isolation: :serializable } : {}
    Session.transaction(**transaction_opts) do
      rooms_by_capacity = rooms.where(schedulable: true).sort_by { |r| -r.capacity }

      timeslots.where(schedulable: true).order(:starts_at).each do |slot|
        log << slot.to_s
        sessions = Session.largest_attendance_first(slot.sessions)

        unless reassign
          assigned, unassigned = sessions.partition(&:room_id?)
          sessions = unassigned
          already_assigned_count += assigned.size
        end

        sessions.zip(rooms_by_capacity) do |session, room|
          if room.nil?
            raise NotEnoughRoomsError,
              "NOT ENOUGH ROOMS: #{slot} has #{slot.sessions.count} sessions, " \
              "but there are only #{rooms_by_capacity.size} schedulable rooms"
          end
          log << "    #{session.id} #{session.title}" \
                 " (#{'%1.1f' % session.expected_attendance} est:" \
                 " #{session.attendances.count} raw vote(s)," \
                 " #{'%1.1f' % session.estimated_interest} time-scaled)" \
                 " in #{room.name} (#{room.capacity})"
          session.room = room
          session.save!
        end
      end
    end

    { log: log, already_assigned_count: already_assigned_count }
  end

  private

  def format_time(time)
    t = time.in_time_zone
    if t.min == 0
      t.strftime('%l%P').strip
    else
      t.strftime('%l:%M%P').strip
    end
  end
end
