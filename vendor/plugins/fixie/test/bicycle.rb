class Bicycle < ActiveRecord::Base
  belongs_to :manufacturer

  validates_uniqueness_of :name
  validates_numericality_of :speeds, :only_integer => true, :greater_than_or_equal_to => 1
  validates_inclusion_of :brakes, :in => [true, false]
end
