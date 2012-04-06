class Session < ActiveRecord::Base
  has_many :categorizations, :dependent => :destroy
  has_many :categories, :through => :categorizations
  belongs_to :participant  # TODO: rename to 'owner'
  has_many :presentations
  has_many :presenters, :through => :presentations, :source => :participant
  belongs_to :event
  belongs_to :timeslot
  belongs_to :room
  has_many :attendances, :dependent => :destroy
  has_many :participants, :through => :attendances

  delegate :name, :to => :room, :prefix => true
  delegate :starts_at, :to => :timeslot

  named_scope :with_attendence_count, :select => '*', :joins => "LEFT OUTER JOIN (SELECT session_id, count(id) AS attendence_count FROM attendances GROUP BY session_id) AS attendence_aggregation ON attendence_aggregation.session_id = sessions.id"

  named_scope :for_current_event, lambda { {:conditions => {:event_id => Event.current_event.id}} }

  validates_presence_of :participant_id
  validates_presence_of :title
  validates_presence_of :description
  validates_length_of :summary, :maximum => 100, :allow_blank => true

  attr_accessor :name, :email

  # TODO: attr_accessible?
  attr_protected :event_id, :timeslot_id, :participant_id, :room_id

  after_create :create_presenter

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
    sessions = Event.current_event.sessions.all(:include => :participants)

    sessions.each do |session|
      prefs = {}

      session.participant_ids.each do |p_id|
        prefs[p_id] = 1
      end

      result[session.id] = prefs
    end

    result
  end

  def self.session_similarity
    Rails.cache.fetch('session_similarity', :expires_in => 30.minutes) do
      preferences = Session.attendee_preferences
      Recommender.calculate_similar_items(preferences, 5)
    end
  end

  def presenter_names
    presenters.map(&:name)
  end


  def attending?(user)
    return false if user.nil?

    participants.include?(user)
  end

  def recommended_sessions
    similarity = Session.session_similarity
    recommended = similarity[self.id]

    if recommended
      # find will not order by recommendation strength; use conditions instead of find to ignore missing sessions in the cache
      sessions = Session.all(:conditions => ["id in (?)", recommended.map { |r| r[1] }])
      sessions.sort_by do |session|
        recommended.find_index { |r| r[1] == session.id }
      end
    else
      []
    end
  end

  private

  # assign the creator as the first presenter
  def create_presenter
    self.presentations.create(:participant => self.participant)
  end
end
