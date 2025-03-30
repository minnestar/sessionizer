class Attendance < ActiveRecord::Base
  belongs_to :session, counter_cache: true
  belongs_to :participant, counter_cache: true

  attr_accessor :name, :email, :password

  validates_presence_of :session_id
  validates_presence_of :participant_id
  validates_uniqueness_of :participant_id, :scope => :session_id
end
