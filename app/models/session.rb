class Session < ActiveRecord::Base
  has_many :categorizations
  has_many :categories, :through => :categorizations
  belongs_to :participant
  has_many :attendances
  has_many :participants, :through => :attendances

  validates_presence_of :participant_id
  validates_presence_of :title
  validates_presence_of :description

  attr_accessor :name, :email

  def attending?(user)
    return false if user.nil?

    participants.include?(user)
  end
end
