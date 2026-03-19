require 'spec_helper'

describe EventCategory do
  it { should belong_to(:event) }
  it { should belong_to(:category) }

  describe 'validations' do
    let(:event) { create(:event) }
    let(:category) { Category.first }

    it 'prevents duplicate event-category pairs' do
      create(:event_category, event: event, category: category)
      duplicate = build(:event_category, event: event, category: category)
      expect(duplicate).not_to be_valid
    end
  end

  describe '.ordered' do
    let(:event) { create(:event) }

    it 'orders by position' do
      cat_a = create(:category, name: 'Zzz Category')
      cat_b = create(:category, name: 'Aaa Category')
      ec_second = create(:event_category, event: event, category: cat_a, position: 2)
      ec_first = create(:event_category, event: event, category: cat_b, position: 1)

      expect(EventCategory.where(event: event).ordered).to eq [ec_first, ec_second]
    end
  end
end
