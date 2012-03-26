class Session < ActiveRecord::Base
  has_many :categorizations, :dependent => :destroy
  has_many :categories, :through => :categorizations
  belongs_to :participant
  belongs_to :event
  belongs_to :timeslot
  has_many :attendances, :dependent => :destroy
  has_many :participants, :through => :attendances

  named_scope :with_attendence_count, :select => '*', :joins => "LEFT OUTER JOIN (SELECT session_id, count(id) AS attendence_count FROM attendances GROUP BY session_id) AS attendence_aggregation ON attendence_aggregation.session_id = sessions.id"

  named_scope :for_current_event, lambda { {:conditions => {:event_id => Event.current_event.id}} }

  validates_presence_of :participant_id
  validates_presence_of :title
  validates_presence_of :description

  attr_accessor :name, :email

  # TODO: attr_accessible?
  attr_protected :event_id, :timeslot_id, :participant_id

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
end
