class Category < ActiveRecord::Base
  has_many :categorizations
  has_many :sessions, :through => :categorizations

  def self.find_or_create_defaults
    cnf = YAML.load_file(File.join(Rails.root, 'config', 'categories.yml'))
    cnf.each do |key, val|
      Category.where(id: key).first_or_initialize.update(name: val)
    end
  end

end
