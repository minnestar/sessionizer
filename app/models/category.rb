class Category < ActiveRecord::Base
  has_many :categorizations
  has_many :sessions, :through => :categorizations
  attr_accessible :name

  def self.find_or_create_defaults
    Category.where(id: 1).first_or_initialize.update_attributes(name: 'Design')
    Category.where(id: 2).first_or_initialize.update_attributes(name: 'Development')
    Category.where(id: 3).first_or_initialize.update_attributes(name: 'Hardware')
    Category.where(id: 4).first_or_initialize.update_attributes(name: 'Startups')
    Category.where(id: 5).first_or_initialize.update_attributes(name: 'Other')
  end

end
