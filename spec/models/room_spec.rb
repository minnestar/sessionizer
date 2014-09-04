require 'spec_helper'

describe Room do
  subject { create(:event).rooms.create!(:name => 'Asdf', :capacity => 100) }
  it { should have_many :sessions }
  it { should belong_to :event }

  it { should validate_numericality_of :capacity }
  it {should validate_presence_of :event_id }
  it {should validate_presence_of :name }
  it {should validate_uniqueness_of(:name).scoped_to(:event_id) }
end
