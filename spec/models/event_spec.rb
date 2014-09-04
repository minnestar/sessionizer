require 'spec_helper'

describe Event do
  subject { Event.new(name: 'Foobar', date: Date.today) }

  it { should validate_presence_of :name }
  it { should validate_presence_of :date }
  it { should have_many :sessions }
  it { should have_many :timeslots }
  it { should have_many :rooms }

  context "creating a new event" do
    before { create(:event, date: 2.months.ago) }
    it "should clear the existing current_event" do
      expect { create(:event) }.to change { Event.current_event }
    end
  end
end
