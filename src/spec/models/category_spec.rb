require 'spec_helper'

describe Category do
  describe '.find_or_create_defaults' do
    before do
      Category.destroy_all
    end

    subject { described_class.find_or_create_defaults }

    it "adds the defaults" do
      expect { subject }.to change { Category.count }.by 5
    end

  end
end
