class Categorization < ActiveRecord::Base
  belongs_to :session
  belongs_to :category

  def self.ransackable_attributes(auth_object = nil)
    %w[category_id]
  end
end
