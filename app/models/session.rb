class Session < ActiveRecord::Base
  has_many :categorizations, :dependent => :destroy
  has_many :categories, :through => :categorizations
  belongs_to :participant
  belongs_to :event
  has_many :attendances, :dependent => :destroy
  has_many :participants, :through => :attendances

  named_scope :with_attendence_count, :select => '*', :joins => "LEFT OUTER JOIN (SELECT session_id, count(id) AS attendence_count FROM attendances GROUP BY session_id) AS attendence_aggregation ON attendence_aggregation.session_id = sessions.id"

  named_scope :for_current_event, lambda { {:conditions => {:event_id => Event.current_event.id}} }

  validates_presence_of :participant_id
  validates_presence_of :title
  validates_presence_of :description

  attr_accessor :name, :email

  def attending?(user)
    return false if user.nil?

    participants.include?(user)
  end
end
