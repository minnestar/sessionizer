require 'spec_helper'

describe Timeslot do
  it { should validate_presence_of :event_id }
  it { should validate_presence_of :starts_at }
  it { should validate_presence_of :ends_at }
  it { should belong_to :event }
end
