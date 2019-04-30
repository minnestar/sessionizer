require "spec_helper"

RSpec.describe SessionsJsonBuilder do
  let(:event) { create(:event) }
  let(:session) { create(:session, event: event, participant: create(:luke)) }

  describe '#to_hash' do
    let(:builder) { SessionsJsonBuilder.new }
    subject(:h) { builder.to_hash(session) }

    it 'has all the attributes' do
      expect(h[:id]).to be session.id
      expect(h[:participant_id]).to be session.participant_id

      expect(h[:presenter_name]).to be session.participant.name
      expect(h[:presenter_twitter_handle]).to be session.participant.twitter_handle
      expect(h[:presenter_github_username]).to be session.participant.github_profile_username
      expect(h[:presenter_github_og_image]).to be session.participant.github_og_image
      expect(session.participant.bio).to_not be_nil
      expect(h[:presenter_bio]).to be session.participant.bio
      expect(h[:session_title]).to be session.title
      expect(h[:summary]).to be session.summary
      expect(h[:description]).to be session.description
      expect(h[:room_name]).to be session.room_name
      expect(h[:panel]).to be session.panel
      expect(h[:projector]).to be session.projector
      expect(h[:starts_at]).to be session.starts_at
      expect(h[:level_name]).to be session.level_name
      expect(h[:categories]).to match_array session.categories.map(&:name)
      expect(h[:other_presenter_names]).to match_array session.other_presenter_names
      expect(h[:other_presenter_ids]).to match_array session.other_presenters.map(&:id)
      expect(h[:attendance_count]).to be session.attendances.count
      expect(h[:created_at]).to be session.created_at.utc
      expect(h[:updated_at]).to be session.updated_at.utc
    end
  end
end
