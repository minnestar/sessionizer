require 'spec_helper'

describe Event do
  subject { Event.new(name: 'Foobar', date: Date.today) }

  it { should validate_presence_of :name }
  it { should validate_presence_of :date }
  it { should have_many :sessions }
  it { should have_many :timeslots }
  it { should have_many :rooms }
  it { should have_many :event_categories }
  it { should have_many :categories }

  context "creating a new event" do
    before { create(:event, date: 2.months.ago) }
    it "should clear the existing current_event" do
      expect { create(:event) }.to change { Event.current_event }
    end
  end

  describe '#categories' do
    let(:event) { create(:event) }

    it 'automatically creates default categories after event creation' do
      expect(event.categories.count).to eq Category.active.count
    end

    it 'does not overwrite categories if already present' do
      original_count = event.event_categories.count
      event.create_default_categories
      expect(event.event_categories.count).to eq original_count
    end

    it 'returns categories linked through event_categories' do
      expect(event.categories).to include(Category.first)
    end

    it 'does not return categories not linked to the event' do
      inactive_cat = create(:category, name: 'Unlinkable Category', active: false)
      expect(event.categories).not_to include(inactive_cat)
    end
  end

  describe "#create_default_rooms" do
    let(:event) { create(:event) }

    context "when event has no rooms" do
      it "creates rooms from the default configuration" do
        active_count = Settings.default_rooms.count { |r| r["active"] != false }
        expect {
          event.create_default_rooms
        }.to change { event.rooms.count }.from(0).to(active_count)
      end

      it "skips inactive rooms" do
        allow(Settings).to receive(:default_rooms).and_return([
          { "name" => "Theater", "capacity" => 250 },
          { "name" => "Alaska", "capacity" => 96, "active" => false, "notes" => "daycare" }
        ])

        event.create_default_rooms
        expect(event.rooms.count).to eq(1)
        expect(event.rooms.first.name).to eq("Theater")
      end

      it "sets correct name and capacity on each room" do
        allow(Settings).to receive(:default_rooms).and_return([
          { "name" => "Theater", "capacity" => 250 },
          { "name" => "Challenge", "capacity" => 24 }
        ])

        event.create_default_rooms
        theater = event.rooms.find_by(name: "Theater")
        expect(theater.capacity).to eq(250)
      end

      it "respects the schedulable flag from config" do
        allow(Settings).to receive(:default_rooms).and_return([
          { "name" => "Theater", "capacity" => 250 },
          { "name" => "Uptowner", "capacity" => 85, "schedulable" => false }
        ])

        event.create_default_rooms
        expect(event.rooms.find_by(name: "Theater").schedulable).to be true
        expect(event.rooms.find_by(name: "Uptowner").schedulable).to be false
      end

      it "defaults schedulable to true when not specified" do
        allow(Settings).to receive(:default_rooms).and_return([
          { "name" => "Theater", "capacity" => 250 }
        ])

        event.create_default_rooms
        expect(event.rooms.find_by(name: "Theater").schedulable).to be true
      end
    end

    context "when event already has rooms" do
      before do
        create(:room, event: event)
      end

      it "raises an error" do
        expect {
          event.create_default_rooms
        }.to raise_error(/#{event.name}.*already has rooms/)
      end

      it "replaces existing rooms when force: true" do
        allow(Settings).to receive(:default_rooms).and_return([
          { "name" => "Theater", "capacity" => 250 },
          { "name" => "Challenge", "capacity" => 24 }
        ])

        event.create_default_rooms(force: true)
        expect(event.rooms.count).to eq(2)
        expect(event.rooms.pluck(:name)).to contain_exactly("Theater", "Challenge")
      end
    end
  end

  describe "#create_default_timeslots" do
    let(:event) { create(:event) }

    context "when event has no timeslots" do
      it "creates all timeslots from the default configuration" do
        expect {
          event.create_default_timeslots
        }.to change { event.timeslots.count }.from(0).to(Settings.default_timeslots.size)
      end

      it "creates special timeslots with correct attributes" do
        event.create_default_timeslots

        registration = event.timeslots.find_by(title: "Registration / Breakfast")
        expect(registration).to be_present
        expect(registration.schedulable).to be false
        expect(registration.starts_at.strftime("%H:%M")).to eq "08:00"
        expect(registration.ends_at.strftime("%H:%M")).to eq "08:30"
      end

      it "creates regular session timeslots with correct attributes" do
        event.create_default_timeslots

        regular_sessions = event.timeslots.where(schedulable: true)
        expect(regular_sessions.count).to eq 7 # Number of regular sessions in config

        first_session = regular_sessions.order(:starts_at).first
        expect(first_session.title).to eq "Session 1"
        expect(first_session.starts_at.strftime("%H:%M")).to eq "09:35"
        expect(first_session.ends_at.strftime("%H:%M")).to eq "10:15"
      end

      it "numbers sessions sequentially" do
        event.create_default_timeslots

        session_numbers = event.timeslots
          .where(schedulable: true)
          .map { |t| t.title.match(/Session (\d+)/)[1].to_i }

        expect(session_numbers).to eq (1..7).to_a
      end
    end

    context "when event already has timeslots" do
      before do
        create(:timeslot, event: event)
      end

      it "raises an error" do
        expect {
          event.create_default_timeslots
        }.to raise_error(/#{event.name}.*already has timeslots/)
      end
    end

    context "when timeslot lengths are inconsistent" do
      before do
        allow(Settings).to receive(:default_timeslots).and_return([
          { "start" => "9:00", "end" => "9:45" },
          { "start" => "10:00", "end" => "10:30" } # Different length
        ])
      end

      it "logs a warning" do
        expect(Rails.logger).to receive(:warn).with(/WARNING: Session 2 is a different length/)
        event.create_default_timeslots
      end
    end
  end

  describe "#starts_within?" do
    it "is true when the event starts in less than the given duration" do
      event = build(:event, date: Date.current, start_time: Time.current + 1.hour)
      expect(event.starts_within?(24.hours)).to be true
    end

    it "is true when the event has already started" do
      event = build(:event, date: Date.current, start_time: Time.current - 1.hour)
      expect(event.starts_within?(24.hours)).to be true
    end

    it "is false when the event starts after the given duration" do
      event = build(:event, date: 5.days.from_now.to_date, start_time: 5.days.from_now)
      expect(event.starts_within?(24.hours)).to be false
    end

    it "is false right at the boundary" do
      event = build(:event, date: 2.days.from_now.to_date, start_time: 2.days.from_now)
      expect(event.starts_within?(24.hours)).to be false
    end

    it "is false when the date is nil" do
      event = build(:event, date: nil, start_time: nil, end_time: nil)
      expect(event.starts_within?(24.hours)).to be false
    end

    it "falls back to start of day when start_time is nil" do
      tomorrow = Date.current + 1.day
      event = build(:event, date: tomorrow, start_time: nil)
      expect(event.starts_within?(24.hours)).to be true
      expect(event.starts_within?(1.hour)).to be false
    end
  end

  describe "#has_unassigned_sessions?" do
    let(:event) { create(:event) }
    let(:slot) { create(:timeslot_1, event: event, schedulable: true) }

    it "is true when a schedulable-timeslot session has no room" do
      create(:session, :without_room, event: event, timeslot: slot)
      expect(event.has_unassigned_sessions?).to be true
    end

    it "is false when all schedulable-timeslot sessions have rooms" do
      create(:session, event: event, timeslot: slot)
      expect(event.has_unassigned_sessions?).to be false
    end

    it "ignores manually_scheduled sessions" do
      create(:session, :without_room, event: event, timeslot: slot, manually_scheduled: true)
      expect(event.has_unassigned_sessions?).to be false
    end

    it "ignores sessions in non-schedulable timeslots" do
      special_slot = create(:timeslot, event: event, schedulable: false)
      create(:session, :without_room, event: event, timeslot: special_slot)
      expect(event.has_unassigned_sessions?).to be false
    end
  end

  describe "#assign_rooms!" do
    let(:event) { create(:event) }
    let!(:big_room) { create(:room, event: event, name: "Theater", capacity: 250) }
    let!(:medium_room) { create(:room, event: event, name: "Harriet", capacity: 100) }
    let!(:small_room) { create(:room, event: event, name: "Challenge", capacity: 24) }
    let!(:slot) { create(:timeslot_1, event: event, schedulable: true) }

    def session_in_slot(attrs = {})
      create(:session, :without_room, attrs.merge(event: event, timeslot: slot))
    end

    it "assigns rooms to sessions in the schedulable timeslot" do
      session = session_in_slot
      expect {
        event.assign_rooms!
      }.to change { session.reload.room }.from(nil)
    end

    it "assigns higher-capacity rooms to sessions with more expected attendance" do
      popular = session_in_slot(manual_attendance_estimate: 200)
      unpopular = session_in_slot(manual_attendance_estimate: 5)

      event.assign_rooms!

      expect(popular.reload.room).to eq(big_room)
      expect(unpopular.reload.room).to eq(medium_room)
    end

    it "skips sessions that already have a room by default" do
      preassigned = session_in_slot
      preassigned.update!(room: small_room)

      event.assign_rooms!

      expect(preassigned.reload.room).to eq(small_room)
    end

    it "reports already-assigned sessions in the result" do
      session_in_slot.update!(room: small_room)
      session_in_slot.update!(room: medium_room)

      result = event.assign_rooms!

      expect(result[:already_assigned_count]).to eq(2)
    end

    it "reassigns existing rooms when reassign: true" do
      session = session_in_slot(manual_attendance_estimate: 200)
      session.update!(room: small_room)

      event.assign_rooms!(reassign: true)

      expect(session.reload.room).to eq(big_room)
    end

    it "ignores non-schedulable timeslots" do
      special_slot = create(:timeslot, event: event, schedulable: false)
      special_session = create(:session, :without_room, event: event, timeslot: special_slot)

      event.assign_rooms!

      expect(special_session.reload.room).to be_nil
    end

    it "raises NotEnoughRoomsError and rolls back when sessions exceed rooms" do
      4.times { session_in_slot }  # 4 sessions, only 3 rooms

      expect {
        event.assign_rooms!
      }.to raise_error(Event::NotEnoughRoomsError, /NOT ENOUGH ROOMS/)

      expect(event.sessions.where.not(room_id: nil)).to be_empty
    end

    it "ignores non-schedulable rooms when distributing" do
      special_room = create(:room, event: event, name: "Atrium", capacity: 500, schedulable: false)
      session = session_in_slot(manual_attendance_estimate: 999)

      event.assign_rooms!

      expect(session.reload.room).to eq(big_room)
      expect(special_room.sessions.reload).to be_empty
    end

    it "leaves manually_scheduled sessions alone, even when reassigning" do
      manual = create(:session, event: event, timeslot: slot, manually_scheduled: true)
      manual.update_column(:room_id, small_room.id)

      event.assign_rooms!(reassign: true)

      expect(manual.reload.room).to eq(small_room)
    end

    it "raises NotEnoughRoomsError when not enough schedulable rooms exist" do
      create(:room, event: event, name: "Atrium", capacity: 500, schedulable: false)
      4.times { session_in_slot }  # 4 sessions, 3 schedulable rooms (Atrium doesn't count)

      expect {
        event.assign_rooms!
      }.to raise_error(Event::NotEnoughRoomsError, /3 schedulable rooms/)
    end

    it "returns a log of slot and session assignments" do
      session = session_in_slot

      result = event.assign_rooms!

      expect(result[:log]).to include(slot.to_s)
      expect(result[:log].any? { |line| line.include?(session.title) && line.include?(big_room.name) }).to be true
    end
  end
end
