require 'spec_helper'

describe EventCategory do
  it { should belong_to(:event) }
  it { should belong_to(:category) }

  describe 'validations' do
    let(:event) { create(:event) }

    it 'prevents duplicate event-category pairs' do
      existing = event.event_categories.first
      duplicate = build(:event_category, event: event, category: existing.category)
      expect(duplicate).not_to be_valid
    end
  end

  describe '.ordered' do
    let(:event) { create(:event) }

    it 'orders by position' do
      ordered = event.event_categories.ordered
      positions = ordered.map(&:position)
      expect(positions).to eq positions.sort
    end
  end
end
