class Session < ActiveRecord::Base

  has_many :categorizations, :dependent => :destroy
  has_many :categories, :through => :categorizations
  belongs_to :participant  # TODO: rename to 'owner'

  has_many :presentations, :dependent => :destroy
  has_many :presenters, :through => :presentations, :source => :participant
  belongs_to :event
  belongs_to :timeslot
  belongs_to :room
  belongs_to :level
  has_many :attendances, :dependent => :destroy
  has_many :participants, :through => :attendances

  delegate :name, to: :room, prefix: true, allow_nil: true
  delegate :starts_at, to: :timeslot, allow_nil: true
  delegate :name, to: :level, prefix: true, allow_nil: true

  scope :with_attendence_count, -> { select('*').joins("LEFT OUTER JOIN (SELECT session_id, count(id) AS attendence_count FROM attendances GROUP BY session_id) AS attendence_aggregation ON attendence_aggregation.session_id = sessions.id") }

  scope :for_current_event, -> { where(event_id: Event.current_event.id) }

  scope :random_order, -> { order('random()') }  # Slow, but fast enough when only ~100 rows

  validates_presence_of :description
  validates_presence_of :event_id
  validates_presence_of :participant_id
  validates_presence_of :title
  validates_length_of :summary, :maximum => 100, :allow_blank => true
  #validates_uniqueness_of :timeslot_id, :scope => :room_id, :allow_blank => true, :message => 'and room combination already in use'


  attr_accessor :name, :email

  after_create :create_presenter

  def self.swap_timeslot_and_rooms(session_1, session_2)
    Session.transaction do
      session_1.room, session_2.room = session_2.room, session_1.room
      session_1.timeslot, session_2.timeslot = session_2.timeslot, session_1.timeslot
      session_1.save
      session_2.save
    end
  end

  def self.swap_rooms(session_1, session_2)
    if session_1.timeslot != session_2.timeslot
      raise "Sessions must be in the same timeslot to swap"
    end

    Session.transaction do
      session_1.room, session_2.room = session_2.room, session_1.room
      session_1.save
      session_2.save
    end
  end

  def self.attendee_preferences
    result = {}
    sessions = Event.current_event.sessions.includes(:participants)

    sessions.each do |session|
      prefs = {}

      session.participant_ids.each do |p_id|
        prefs[p_id] = 1
      end

      result[session.id] = prefs
    end

    result
  end


  def self.session_similarity()
    Rails.cache.fetch('session_similarity', :expires_in => 30.minutes) do
      preferences = Session.attendee_preferences
      ::Recommender.calculate_similar_items(preferences, 5)
    end
  end

  def presenter_names
    presenters.map(&:name)
  end

  def other_presenters
    presenters.reject{ |p| p == self.participant }
  end
  def other_presenter_names
    other_presenters.map(&:name)
  end


  def attending?(user)
    return false if user.nil?

    participants.include?(user)
  end

  def recommended_sessions
    similarity = Session.session_similarity()
    recommended = similarity[self.id]

    if recommended
      # find will not order by recommendation strength; use conditions instead of find to ignore missing sessions in the cache
      sessions = Session.where(["id in (?)", recommended.map { |r| r[1] }])
      sessions.sort_by do |session|
        recommended.find_index { |r| r[1] == session.id }
      end
    else
      []
    end
  end

  # Estimates actual event-day interest for this session relative to other sessions,
  # expressed as a corrected number of votes.
  #
  # Sessions that were created earlier tend to accumulate more votes, so the naive method
  # of using raw vote count will underestimate interest in sessions created later.
  # To fix that, we take the number of votes this session received as a proportion of all
  # votes cast since it was created. We also include a normalizing factor for last-minute
  # sessions created after most of the voting was already done.
  #
  def estimated_interest
    @estimated_interest ||= begin
      session_votes     = attendances.count.to_f
      possible_votes    = event.attendances.where('attendances.created_at >= ?', created_at).count.to_f
      session_count     = event.sessions.count.to_f
      participant_count = event.participants.count.to_f

      # For sessions created at the last minute, we don't have enough information to make
      # a good estimate; both session_votes and possible_votes are too low. If we just divide
      # session_votes / possible_votes, we'll get wildly inaccurate answers when the denominator
      # is small.
      #
      # We therefore add some ghost "ballast votes" across the board to all sessions, so as to
      # make estimated_interest tend toward the mean in cases when there are few real votes.

      ballast_votes = 3.0

      (session_votes + ballast_votes) / (possible_votes + ballast_votes * session_count) * participant_count
    end
  end

  def to_h
    SessionsJsonBuilder.new.to_hash(self)
  end

  private

  # assign the creator as the first presenter
  def create_presenter
    presentations.create(participant: participant)
  end

end
