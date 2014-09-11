class Category < ActiveRecord::Base
  has_many :categorizations
  has_many :sessions, :through => :categorizations

  def self.find_or_create_defaults
    Category.where(id: 1).first_or_initialize.update(name: 'Design')
    Category.where(id: 2).first_or_initialize.update(name: 'Development')
    Category.where(id: 3).first_or_initialize.update(name: 'Hardware')
    Category.where(id: 4).first_or_initialize.update(name: 'Startups')
    Category.where(id: 5).first_or_initialize.update(name: 'Other')
  end

end
