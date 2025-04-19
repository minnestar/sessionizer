require "spec_helper"

describe Settings do
  describe ".show_schedule?" do
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

  describe "#default_timeslots" do
    let(:settings) { Settings.instance }

    context "with valid input" do
      it "accepts array of timeslot hashes" do
        valid_timeslots = [
          { "start" => "8:00", "end" => "8:30", "special" => "Breakfast" },
          { "start" => "8:30", "end" => "9:00" }
        ]
        settings.default_timeslots = valid_timeslots
        expect(settings).to be_valid
      end

      it "accepts JSON string with multiple timeslots" do
        valid_input = "{\"start\":\"8:00\", \"end\":\"8:30\", \"special\":\"Breakfast\"},\r\n" +
                     "{\"start\":\"8:30\", \"end\":\"9:00\"}"
        settings.default_timeslots = valid_input
        expect(settings).to be_valid
      end

      it "handles blank lines and trailing commas" do
        json_string = <<~JSON
          {"start":"8:00", "end":"8:30"},

          {"start":"8:30", "end":"9:00"},
        JSON
        settings.default_timeslots = json_string
        expect(settings).to be_valid
      end
    end

    context "with invalid input" do
      it "rejects malformed JSON" do
        settings.default_timeslots = "{\"start\":\"8:00\", \"end\":\"8:30\",}"
        expect(settings).not_to be_valid
        expect(settings.errors[:default_timeslots]).to include(/Invalid JSON format/)
        expect(settings.default_timeslots_raw_value).to eq("{\"start\":\"8:00\", \"end\":\"8:30\",}")
      end

      it "rejects timeslots with missing required fields" do
        settings.default_timeslots = [{ "start" => "8:00" }]
        expect(settings).not_to be_valid
        expect(settings.errors[:default_timeslots]).to include("line 1 is missing required start or end time")
      end

      it "rejects invalid time formats" do
        settings.default_timeslots = [{ "start" => "invalid", "end" => "8:30" }]
        expect(settings).not_to be_valid
        expect(settings.errors[:default_timeslots]).to include("line 1 has invalid time format")
      end

      it "rejects invalid time order" do
        settings.default_timeslots = [{ "start" => "9:00", "end" => "8:30" }]
        expect(settings).not_to be_valid
        expect(settings.errors[:default_timeslots]).to include("line 1 has end time before or equal to start time")
      end
    end
  end
end
