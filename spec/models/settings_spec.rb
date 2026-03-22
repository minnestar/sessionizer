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

  describe "#default_rooms" do
    let(:settings) { Settings.instance }

    context "with no saved config" do
      it "falls back to static defaults" do
        rooms = Settings.default_rooms
        expect(rooms).to be_an(Array)
        expect(rooms.size).to eq(Settings.static_default_rooms.size)
        expect(rooms.first["name"]).to eq("Bde Maka Ska")
      end
    end

    context "with valid input" do
      it "accepts array of room hashes" do
        valid_rooms = [
          { "name" => "Theater", "capacity" => 250 },
          { "name" => "Alaska", "capacity" => 96, "active" => false, "notes" => "Used for daycare" }
        ]
        settings.default_rooms = valid_rooms
        expect(settings).to be_valid
      end

      it "accepts JSON string with multiple rooms" do
        valid_input = "{\"name\":\"Theater\", \"capacity\":250},\r\n" \
                     "{\"name\":\"Alaska\", \"capacity\":96, \"active\":false, \"notes\":\"daycare\"}"
        settings.default_rooms = valid_input
        expect(settings).to be_valid
      end

      it "handles blank lines and trailing commas" do
        json_string = <<~JSON
          {"name":"Theater", "capacity":250},

          {"name":"Alaska", "capacity":96},
        JSON
        settings.default_rooms = json_string
        expect(settings).to be_valid
      end

      it "preserves optional fields" do
        settings.default_rooms = [
          { "name" => "Alaska", "capacity" => 96, "active" => false, "notes" => "daycare" }
        ]
        expect(settings).to be_valid
        expect(settings.default_rooms.first["active"]).to eq(false)
        expect(settings.default_rooms.first["notes"]).to eq("daycare")
      end
    end

    context "with invalid input" do
      it "rejects malformed JSON" do
        settings.default_rooms = "{\"name\":\"Theater\", \"capacity\":250,}"
        expect(settings).not_to be_valid
        expect(settings.errors[:default_rooms]).to include(/Invalid JSON format/)
      end

      it "rejects rooms with missing name" do
        settings.default_rooms = [{ "capacity" => 250 }]
        expect(settings).not_to be_valid
        expect(settings.errors[:default_rooms]).to include("line 1 is missing required name")
      end

      it "rejects rooms with missing capacity" do
        settings.default_rooms = [{ "name" => "Theater" }]
        expect(settings).not_to be_valid
        expect(settings.errors[:default_rooms]).to include("line 1 has invalid capacity (must be a positive integer)")
      end

      it "rejects rooms with non-positive capacity" do
        settings.default_rooms = [{ "name" => "Theater", "capacity" => 0 }]
        expect(settings).not_to be_valid
        expect(settings.errors[:default_rooms]).to include("line 1 has invalid capacity (must be a positive integer)")
      end
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
