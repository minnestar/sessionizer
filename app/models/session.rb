class Session < ActiveRecord::Base
  has_many :categorizations
  has_many :categories, :through => :categorizations
end
