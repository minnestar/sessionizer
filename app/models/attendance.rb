class Attendance < ActiveRecord::Base
  belongs_to :session, counter_cache: true
  belongs_to :participant, counter_cache: true

  attr_accessor :name, :email, :password

  validates :session_id, presence: true
  validates :participant_id, presence: true
  validates :participant_id, uniqueness: {scope: :session_id}
end
