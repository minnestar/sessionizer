require "spec_helper"

describe Session do
  it { should have_many(:categorizations) }
  it { should have_many(:categories) }
  it { should belong_to(:participant) }
  it { should have_many(:presentations) }
  it { should have_many(:presenters) }
  it { should belong_to(:event) }
  it { should belong_to(:timeslot) }
  it { should belong_to(:room) }
  it { should have_many(:attendances) }
  it { should have_many(:participants) }

  describe "creation" do
    let(:participant) { stub_model(Participant) }
    subject {
      participant.sessions.build(title: 'Some Title', description: 'some desc').tap do |s|
        s.event = FactoryGirl.create(:event)
        s.save!
      end

    }

    it "should create a presenter after create" do
      expect(subject.presentations).to have(1).thing
    end

  end

end
