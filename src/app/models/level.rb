# == Schema Information
#
# Table name: levels
#
#  id   :integer          not null, primary key
#  name :string
#

class Level < ActiveRecord::Base
  has_many :sessions
end
