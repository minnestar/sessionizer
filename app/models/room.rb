class Room < ActiveRecord::Base
  belongs_to :event, counter_cache: true
  has_many :sessions, dependent: :nullify

  # TODO: Deprecate the default scope.
  default_scope { order "capacity desc" }

  validates :capacity, numericality: {greater_than: 0, only_integer: true}
  validates :event_id, presence: true
  validates :name, presence: true
  validates :name, uniqueness: {scope: :event_id}
end
