# == Schema Information
#
# Table name: categorizations
#
#  id          :integer          not null, primary key
#  category_id :integer          not null
#  session_id  :integer          not null
#  created_at  :datetime
#  updated_at  :datetime
#

class Categorization < ActiveRecord::Base
  belongs_to :session
  belongs_to :category
end
