class Category < ActiveRecord::Base
  has_many :categorizations
  has_many :sessions, :through => :categorizations
  attr_accessible :name

end
