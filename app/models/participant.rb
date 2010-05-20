class Participant < ActiveRecord::Base
  has_many :sessions
  has_many :attendances
  has_many :sessions_attending, :through => :attendances, :source => :session

  validates_presence_of :name
  validates_uniqueness_of :email, :case_sensitive => false
end
