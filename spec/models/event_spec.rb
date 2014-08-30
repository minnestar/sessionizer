require 'spec_helper'

describe Event do
  subject { Event.new(name: 'Foobar', date: Date.today) }

  it { should validate_presence_of :name }
  it { should validate_presence_of :date }
  it { should have_many :sessions }
  it { should have_many :timeslots }
  it { should have_many :rooms }
end
