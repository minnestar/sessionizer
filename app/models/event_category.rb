class EventCategory < ActiveRecord::Base
  belongs_to :event
  belongs_to :category

  validates :category_id, uniqueness: { scope: :event_id }

  scope :ordered, -> { order(:position) }
end
