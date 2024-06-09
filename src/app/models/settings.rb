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

end
