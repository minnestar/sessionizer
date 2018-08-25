# == Schema Information
#
# Table name: rooms
#
#  id          :integer          not null, primary key
#  event_id    :integer          not null
#  name        :string           not null
#  capacity    :integer
#  created_at  :datetime
#  updated_at  :datetime
#  schedulable :boolean          default(TRUE)
#

class Room < ActiveRecord::Base
  belongs_to :event
  has_many :sessions, :dependent => :nullify

  # TODO: Deprecate the default scope.
  default_scope { order 'capacity desc' }

  validates_numericality_of :capacity, :greater_than => 0, :only_integer => true
  validates_presence_of :event_id
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :event_id
end
