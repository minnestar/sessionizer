module Recommender

  class << self

    # Returns a distance-based similarity score for person1 and person2
    def distance_similarity(prefs, item1, item2)
      if prefs[item1].nil? || prefs[item2].nil?
        return 0
      end
      
      # Get the list of shared_items
      shared_items = (prefs[item1].keys & prefs[item2].keys)

      # if they have no ratings in common, return 0
      if shared_items.empty?
        return 0
      end
      
      squares = prefs[item1].keys.map do |rating_key|
        if prefs[item2].has_key?(rating_key)
          (prefs[item1][rating_key] - prefs[item2][rating_key]) ** 2
        else
          1.0 # user did not rate => 0 => (1-0)^2 = 1
        end
      end

      return 1/(1+squares.sum)
    end

    # Returns the best matches for person from the prefs dictionary. 
    # Number of results and similarity function are optional params.
    def top_matches(item_prefs, item, number=5)
      scores = []

      item_prefs.keys.each do |other|
        if other != item
          similarity = distance_similarity(item_prefs, item, other)

          if similarity > 0
            scores << [similarity, other]
          end
        end
      end

      scores = scores.sort_by { |score| -score[0] }

      return scores[0, number]
    end

    def calculate_similar_items(item_prefs, number=10)
      # Create a dictionary of items showing which other items they
      # are most similar to.
      result = {}

      item_prefs.keys.each do |item|
        result[item] = top_matches(item_prefs, item, number)
      end
      
      
      return result
    end
  end
end
      
