module Recommender

  class << self

    # Returns a distance-based similarity score for person1 and person2
    def distance_similarity(prefs, person1, person2)
      if prefs[person1].nil? || prefs[person2].nil?
        return 0
      end
      
      # Get the list of shared_items
      shared_items = (prefs[person1].keys & prefs[person2].keys)

      # if they have no ratings in common, return 0
      if shared_items.empty?
        return 0
      end
      
      squares = prefs[person1].map do |item|
        if prefs[person2].include?(item)
          (prefs[person1][item] - prefs[person2][item]) ** 2
        else
          0
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
      
