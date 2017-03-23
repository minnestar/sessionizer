require 'spec_helper'

describe AttendancesController do
  describe "#create" do
    let(:session) { create(:session) }

    context "when logged in" do
      let(:participant) { create(:participant) }

      before do
        activate_authlogic
        ParticipantSession.create(participant)
      end

      context "when the create is successful" do
        context "and the format is html" do
          it "should record the interest" do
            expect {
              post :create, params: {session_id: session}
            }.to change { session.attendances.count }.by(1)
            expect(response).to redirect_to session
            expect(flash[:notice]).to eq "Thanks for your interest in this session."
          end
        end

        context "and the format is json" do
          it "should record the interest" do
            expect {
              post :create, params: {session_id: session}, format: :json
            }.to change { session.attendances.count }.by(1)
            expect(response).to be_successful
            expect(response).to render_template "sessions/_participant"
          end
        end
      end

      context "when the create fails (because they've already signed up once)" do
        before do
          # This is because of mass-assignment security. It can be tidied up with Rails 4.
          Attendance.new.tap do |a|
            a.session = session
            a.participant = participant
            a.save!
          end
        end

        it "should have no effect" do
          expect {
            post :create, params: {session_id: session, format: :json}
          }.to_not change { session.attendances.count }
          expect(response).to be_successful
          expect(response).to render_template "sessions/_participant"
        end
      end
    end

    context "when not logged in" do
      let(:user) { build(:participant) }

      context "when the create is successful" do
        context "and the format is html" do
          it "should record the interest" do
            expect {
              post :create, params: {session_id: session, attendance: {
                                                  name: 'Charles Babbage',
                                                  email: 'chuck_engine_light@example.org',
                                                  password: 'analytical' }
                                    }
            }.to change { session.attendances.count }.by(1)
            expect(response).to redirect_to session
            expect(flash[:notice]).to eq "Thanks for your interest in this session."
          end
        end
      end
    end
  end
end
