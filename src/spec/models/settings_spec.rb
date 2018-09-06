# == Schema Information
#
# Table name: settings
#
#  id               :integer          not null, primary key
#  show_schedule    :boolean
#  current_event_id :integer
#

require 'spec_helper'

describe Settings do
  describe '.show_schedule?' do
    it "is initially false" do
      expect(Settings.show_schedule?).to be false
    end

    it "is settable" do
      Settings.show_schedule = true
      expect(Settings.show_schedule?).to be true
      Settings.show_schedule = false
      expect(Settings.show_schedule?).to be false
    end
  end

end
