class Session < ActiveRecord::Base
  has_many :categorizations
  has_many :categories, :through => :categorizations
  belongs_to :participant

  validates_presence_of :participant_id

  attr_accessor :name, :email
end
