class Settings < ActiveRecord::Base

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

  def self.default_timeslot_config
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

end
