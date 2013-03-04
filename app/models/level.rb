class Level < ActiveRecord::Base
  has_many :sessions
  attr_accessible :name
end
