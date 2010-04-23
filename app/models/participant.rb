class Participant < ActiveRecord::Base
  has_many :sessions

  validates_presence_of :name
  validates_uniqueness_of :email, :case_sensitive => false
end
