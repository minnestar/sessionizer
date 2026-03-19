require 'spec_helper'

describe Category do
  it { should have_many(:categorizations) }
  it { should have_many(:sessions) }
  it { should have_many(:event_categories) }
  it { should have_many(:events) }

  describe '.find_or_create_defaults' do
    before do
      Category.destroy_all
    end

    subject { described_class.find_or_create_defaults }

    it "creates all default categories" do
      expect { subject }.to change { Category.count }.by(Category::ALL_DEFAULTS.size)
    end

    it "is idempotent" do
      subject
      expect { described_class.find_or_create_defaults }.not_to change { Category.count }
    end
  end

  describe '#display_long_name' do
    it 'returns long_name when present' do
      category = Category.new(name: 'Design', long_name: 'Product & UX Design')
      expect(category.display_long_name).to eq 'Product & UX Design'
    end

    it 'falls back to name when long_name is nil' do
      category = Category.new(name: 'Development', long_name: nil)
      expect(category.display_long_name).to eq 'Development'
    end
  end

  describe 'scopes' do
    describe '.active' do
      it 'returns only active categories' do
        active_cat = Category.first
        inactive_cat = create(:category, name: 'Inactive Cat', active: false)

        expect(Category.active).to include(active_cat)
        expect(Category.active).not_to include(inactive_cat)
      end
    end

    describe '.default_order' do
      before do
        Category.update_all(active: true)
        Category.find_by(name: 'Design').update!(default_position: 1)
        Category.find_by(name: 'Development').update!(default_position: 2)
        Category.find_by(name: 'Hardware').update!(default_position: 3)
        Category.find_by(name: 'Startups').update!(default_position: 4)
        Category.find_by(name: 'Other').update!(default_position: 5)
      end

      it 'returns active categories ordered by default_position' do
        result = Category.default_order
        expect(result.first.name).to eq 'Design'
        expect(result.second.name).to eq 'Development'
      end

      it 'excludes inactive categories' do
        Category.find_by(name: 'Hardware').update!(active: false)
        expect(Category.default_order.map(&:name)).not_to include('Hardware')
      end
    end
  end

  describe '.create_defaults_for_event' do
    let(:event) { create(:event) }

    it 'creates event_categories linking active categories to the event' do
      expect(event.categories.count).to eq Category.active.count
    end

    it 'assigns positions based on default_position' do
      dev_ec = event.event_categories.joins(:category).where(categories: { name: 'Development' }).first
      design_ec = event.event_categories.joins(:category).where(categories: { name: 'Design' }).first

      expect(dev_ec.position).to eq Category.find_by(name: 'Development').default_position
      expect(design_ec.position).to eq Category.find_by(name: 'Design').default_position
    end

    it 'is idempotent - does not create duplicates' do
      expect {
        Category.create_defaults_for_event(event)
      }.not_to change { event.event_categories.count }
    end
  end
end
