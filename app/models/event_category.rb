class EventCategory < ActiveRecord::Base
  belongs_to :event
  belongs_to :category

  validates :category_id, uniqueness: { scope: :event_id }

  scope :ordered, -> { order(:position) }

  def self.ransackable_attributes(auth_object = nil)
    %w[category_id event_id position]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[event category]
  end
end
