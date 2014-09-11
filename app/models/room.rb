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
