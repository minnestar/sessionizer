require 'spec_helper'

describe Recommender do

  let(:preferences) { {
      'item1' => { 'user1' => 1.0, 'user2' => 1.0 },
      'item2' => { 'user1' => 1.0, 'user2' => 1.0 },
      'item3' => { 'user1' => 1.0 },
      'item4' => { 'user2' => 1.0 },
      'item5' => { 'user1' => 1.0, 'user2' => 1.0, 'user3' => 1.0}
    }
  }

  describe "#distance_similarity" do
    it "should return 0 when either item is not found in preferences" do
      expect(Recommender.distance_similarity(preferences, 'item666', 'item1')).to eq 0

    end

    it "should return 0 for no shared items" do
      expect(Recommender.distance_similarity(preferences, 'item3', 'item4')).to eq 0
    end

    it "should return sum of squares of differences for shared items" do
      expect(Recommender.distance_similarity(preferences, 'item1', 'item2')).to eq 1
      expect(Recommender.distance_similarity(preferences, 'item2', 'item1')).to eq 1

      expect(Recommender.distance_similarity(preferences, 'item1', 'item3')).to eq 0.5
      expect(Recommender.distance_similarity(preferences, 'item5', 'item1')).to eq 0.5

      expect(Recommender.distance_similarity(preferences, 'item5', 'item3')).to eq 1/3.0
    end
  end

end
