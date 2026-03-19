class BackfillEventCategories < ActiveRecord::Migration[7.2]
  def up
    # For every event that has sessions, link the original 5 categories
    event_ids = Session.where("event_id > 0").distinct.pluck(:event_id).compact

    event_ids.each do |event_id|
      Category::LEGACY_DEFAULTS.each_with_index do |attrs, index|
        category = Category.find_by(name: attrs[:name])
        next unless category

        EventCategory.find_or_create_by!(event_id: event_id, category_id: category.id) do |ec|
          ec.position = index + 1
        end
      end
    end
  end

  def down
    EventCategory.delete_all
  end
end
