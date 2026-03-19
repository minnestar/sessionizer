class PopulateCategoryData < ActiveRecord::Migration[7.2]
  def up
    # Fix the Postgres auto-increment sequence for categories.
    # The original 5 categories were seeded with explicit IDs (1-5), which left
    # the sequence counter behind. This syncs it to the actual max ID so that
    # new inserts get the next available ID automatically.
    ActiveRecord::Base.connection.reset_pk_sequence!("categories")

    Category::ALL_DEFAULTS.each do |attrs|
      category = Category.find_or_initialize_by(name: attrs[:name])
      category.assign_attributes(attrs.except(:name))
      category.save!
    end
  end

  def down
    new_names = Category::NEW_DEFAULTS.map { |c| c[:name] }
    Category.where(name: new_names).destroy_all
    Category.update_all(long_name: nil, tagline: nil, description: nil, active: true, default_position: 0)
  end
end
