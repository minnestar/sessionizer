require 'test_helper'

class CategorizationTest < ActiveSupport::TestCase

  def setup
    @preferences = {
      'item1' => { 'user1' => 1.0, 'user2' => 1.0 },
      'item2' => { 'user1' => 1.0, 'user2' => 1.0 },
      'item3' => { 'user1' => 1.0 },
      'item4' => { 'user2' => 1.0 },
      'item5' => { 'user1' => 1.0, 'user2' => 1.0, 'user3' => 1.0}
    }
  end

  test "distance_similarity should return 0 when either item is not found in preferences" do
    assert_equal(0, Recommender.distance_similarity(@preferences, 'item666', 'item1'))

  end

  test "distance_similarity should return 0 for no shared items" do
    assert_equal(0, Recommender.distance_similarity(@preferences, 'item3', 'item4'), "disimilar items should == 0")
  end

  test "distance_similarity should return sum of squares of differences for shared items" do
    assert_equal(1, Recommender.distance_similarity(@preferences, 'item1', 'item2'), "Identical items should == 1")
    assert_equal(1, Recommender.distance_similarity(@preferences, 'item2', 'item1'), "Identical items should == 1")
    assert_equal(0.5, Recommender.distance_similarity(@preferences, 'item1', 'item3'))
    assert_equal(0.5, Recommender.distance_similarity(@preferences, 'item5', 'item1'))
    assert_equal((1/3.0), Recommender.distance_similarity(@preferences, 'item5', 'item3'))
  end

end
