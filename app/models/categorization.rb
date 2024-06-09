class Categorization < ActiveRecord::Base
  belongs_to :session
  belongs_to :category
end
