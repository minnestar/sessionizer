class ActiveRecord::Base
  # given a hash of attributes including the ID, look up the record by ID.
  # If it does not exist, it is created with the rest of the options.
  # If it exists, it is updated with the given options.
  #
  # Raises an exception if the record is invalid to ensure seed data is loaded correctly.
  #
  # Returns the record.
  def self.create_or_update(options = {})
    id = options.delete(:id)
    record = self.where(:id => id).first || new
    record.id = id
    record.attributes = options
    record.save!

    record
  end
end

Level.create_or_update(:id => 1, :name => 'Beginner')
Level.create_or_update(:id => 2, :name => 'Intermediate')
Level.create_or_update(:id => 3, :name => 'Advanced')
Level.create_or_update(:id => 4, :name => 'All levels')
