class Settings < ActiveRecord::Base
  validate :validate_default_timeslots
  validate :validate_default_rooms

  def self.instance
    self.find_or_create_by id: 1
  end

  def self.show_schedule?
    instance.show_schedule?
  end

  def self.show_schedule= val
    instance.update(show_schedule: !!val)
  end

  def self.allow_new_sessions?
    instance.allow_new_sessions?
  end

  def self.allow_new_sessions= val
    instance.update(allow_new_sessions: !!val)
  end

  def self.default_timeslots
    timeslots = instance.default_timeslots.presence || static_default_timeslots
    timeslots.map(&:stringify_keys)
  end

  def self.static_default_timeslots
    [
      { start: "8:00", end: "8:30", special: "Registration / Breakfast" },
      { start: "8:30", end: "8:50", special: "Kickoff" },
      { start: "8:50", end: "9:20", special: "Session 0" },
      { start: "9:30", end: "16:30", special: "All day" },
      { start: "9:35", end: "10:15" },
      { start: "10:30", end: "11:10" },
      { start: "11:25", end: "12:05" },
      { start: "12:05", end: "13:05", special: "Lunch" },
      { start: "13:05", end: "13:45" },
      { start: "14:00", end: "14:40" },
      { start: "14:55", end: "15:35" },
      { start: "15:50", end: "16:30" },
      { start: "16:30", end: "18:30", special: "Social Hour" }
    ]
  end

  def self.default_rooms
    rooms = instance.default_rooms.presence || static_default_rooms
    rooms.map(&:stringify_keys)
  end

  def self.static_default_rooms
    [
      # Active rooms (alphabetical)
      { name: "Bde Maka Ska",    capacity: 100 },
      { name: "Challenge",       capacity:  24 },
      { name: "Cottage",         capacity:   8, notes: "out of the way in the B wing" },
      { name: "Discovery",       capacity:  23, notes: "no video recording" },
      { name: "Florida",         capacity:  12, notes: "TV, no projector" },
      { name: "Gandhi",          capacity:  23, notes: "Previously used for daycare; no video recording" },
      { name: "Georgia",         capacity:  12, notes: "TV, no projector" },
      { name: "Harriet",         capacity: 100 },
      { name: "Kansas",          capacity:  10, notes: "TV, no projector" },
      { name: "Learn",           capacity:  24 },
      { name: "Louis Pasteur",   capacity:  18 },
      { name: "Maine",           capacity:  10 },
      { name: "Maryland",        capacity:  10 },
      { name: "Minnetonka",      capacity: 100 },
      { name: "Nebraska",        capacity:  10 },
      { name: "Nevada",          capacity:  16, notes: "out of the way, but available" },
      { name: "Nokomis",         capacity: 100 },
      { name: "Oklahoma",        capacity:   8 },
      { name: "Pennsylvania",    capacity:  10 },
      { name: "Proverb-Edison",  capacity:  48 },
      { name: "Stephen Leacock", capacity:  23, notes: "Previously used for daycare; no video recording" },
      { name: "Tackle",          capacity:  23, notes: "no video recording" },
      { name: "Texas",           capacity:  16 },
      { name: "Theater",         capacity: 250 },
      { name: "Zeke Landres",    capacity:  40 },

      # Inactive rooms (alphabetical)
      { name: "Alaska",          capacity:  96, active: false, notes: "Used for daycare in 2025" },
      { name: "Brand",           capacity:  75, active: false, notes: "Suboptimal room, reserved for more dire need" },
      { name: "Cabin",           capacity:   9, active: false, notes: "out of the way, not setup for presentations" },
      { name: "California",      capacity:  16, active: false, notes: "behind security turnstiles" },
      { name: "Illinois",        capacity:   7, active: false, notes: "small" },
      { name: "Minnesota",       capacity:   7, active: false, notes: "small" },
      { name: "New York",        capacity:  10, active: false, notes: "Used for staff in 2025" },
      { name: "Oregon",          capacity:  12, active: false, notes: "behind security turnstiles" },
      { name: "South Carolina",  capacity:   6, active: false, notes: "converted to meditation room in 2025" },
      { name: "Washington",      capacity:   7, active: false, notes: "small, out of the way" },
      { name: "Wisconsin",       capacity:   7, active: false, notes: "small" },
    ]
  end

  def default_timeslots=(value)
    # Store the raw value for error display
    @default_timeslots_raw_value = value

    # Handle both string input (from textarea) and array input
    config = if value.is_a?(String)
      begin
        # Split the string by newlines and parse each line as JSON
        value.split(/[\r\n]+/).map do |line|
          # Remove trailing comma if present
          line = line.strip.gsub(/,\s*$/, '')
          next if line.blank?
          JSON.parse(line)
        end.compact
      rescue JSON::ParserError => e
        @default_timeslots_validation_error = "Invalid JSON format: #{e.message}"
        self.class.static_default_timeslots
      end
    else
      value
    end

    # Ensure the value is an array of hashes with the correct structure
    validated_config = Array(config).map do |slot|
      {
        "start" => slot["start"].to_s,
        "end" => slot["end"].to_s,
        "special" => slot["special"].presence
      }.compact
    end
    super(validated_config)
  end

  def default_timeslots_raw_value
    @default_timeslots_raw_value
  end

  def default_timeslots_validation_error
    @default_timeslots_validation_error
  end

  def default_rooms=(value)
    @default_rooms_raw_value = value

    config = if value.is_a?(String)
      begin
        value.split(/[\r\n]+/).map do |line|
          line = line.strip.gsub(/,\s*$/, '')
          next if line.blank?
          JSON.parse(line)
        end.compact
      rescue JSON::ParserError => e
        @default_rooms_validation_error = "Invalid JSON format: #{e.message}"
        self.class.static_default_rooms
      end
    else
      value
    end

    validated_config = Array(config).map do |room|
      normalized = room.to_h.stringify_keys
      entry = {
        "name" => normalized["name"].to_s,
        "capacity" => normalized.key?("capacity") ? normalized["capacity"].to_i : nil,
        "active" => normalized.key?("active") ? normalized["active"] : nil,
        "schedulable" => normalized.key?("schedulable") ? normalized["schedulable"] : nil,
        "notes" => normalized["notes"].presence
      }.compact
      entry["active"] = false if normalized.key?("active") && normalized["active"] == false
      entry["schedulable"] = false if normalized.key?("schedulable") && normalized["schedulable"] == false
      entry
    end
    super(validated_config)
  end

  def default_rooms_raw_value
    @default_rooms_raw_value
  end

  def default_rooms_validation_error
    @default_rooms_validation_error
  end

  private

  def validate_default_rooms
    return unless has_attribute?(:default_rooms) && default_rooms_changed?

    if default_rooms_validation_error.present?
      errors.add(:default_rooms, default_rooms_validation_error)
      return
    end

    unless default_rooms.is_a?(Array)
      errors.add(:default_rooms, "must be an array of JSON objects")
      return
    end

    default_rooms.each_with_index do |room, index|
      unless room.is_a?(Hash)
        errors.add(:default_rooms, "line #{index + 1} must be a valid JSON object")
        next
      end

      unless room["name"].present?
        errors.add(:default_rooms, "line #{index + 1} is missing required name")
        next
      end

      unless room["capacity"].present?
        errors.add(:default_rooms, "line #{index + 1} is missing required capacity")
        next
      end

      if room["capacity"].to_i <= 0
        errors.add(:default_rooms, "line #{index + 1} has invalid capacity (must be a positive integer)")
      end
    end
  end

  def validate_default_timeslots
    return unless has_attribute?(:default_timeslots) && default_timeslots_changed?

    # Check for any validation errors from the setter
    if default_timeslots_validation_error.present?
      errors.add(:default_timeslots, default_timeslots_validation_error)
      return
    end

    # Ensure it's an array
    unless default_timeslots.is_a?(Array)
      errors.add(:default_timeslots, "must be an array of JSON objects")
      return
    end

    # Validate each timeslot
    default_timeslots.each_with_index do |slot, index|
      # Check that it's a hash/object
      unless slot.is_a?(Hash)
        errors.add(:default_timeslots, "line #{index + 1} must be a valid JSON object")
        next
      end

      # Check required fields
      unless slot["start"].present? && slot["end"].present?
        errors.add(:default_timeslots, "line #{index + 1} is missing required start or end time")
        next
      end

      # Validate time format
      begin
        Time.parse(slot["start"])
        Time.parse(slot["end"])
      rescue ArgumentError
        errors.add(:default_timeslots, "line #{index + 1} has invalid time format")
      end

      # Validate time order
      begin
        start_time = Time.parse(slot["start"])
        end_time = Time.parse(slot["end"])
        if end_time <= start_time
          errors.add(:default_timeslots, "line #{index + 1} has end time before or equal to start time")
        end
      rescue ArgumentError
        # Skip this check if time parsing failed (already caught above)
      end
    end
  end
end
