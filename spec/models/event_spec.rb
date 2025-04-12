require 'spec_helper'

describe Event do
  subject { Event.new(name: 'Foobar', date: Date.today) }

  it { should validate_presence_of :name }
  it { should validate_presence_of :date }
  it { should have_many :sessions }
  it { should have_many :timeslots }
  it { should have_many :rooms }

  context "creating a new event" do
    before { create(:event, date: 2.months.ago) }
    it "should clear the existing current_event" do
      expect { create(:event) }.to change { Event.current_event }
    end
  end

  describe "#create_default_timeslots" do
    let(:event) { create(:event) }

    context "when event has no timeslots" do
      it "creates all timeslots from the default configuration" do
        expect {
          event.create_default_timeslots
        }.to change { event.timeslots.count }.from(0).to(Settings.default_timeslot_config.size)
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
        allow(Settings).to receive(:default_timeslot_config).and_return([
          { start: "9:00", end: "9:45" },
          { start: "10:00", end: "10:30" } # Different length
        ])
      end

      it "logs a warning" do
        expect(Rails.logger).to receive(:warn).with(/WARNING: Session 2 is a different length/)
        event.create_default_timeslots
      end
    end
  end
end
