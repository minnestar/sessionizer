class AttendancesController < ApplicationController
  before_action :create_participant, only: :create

  load_resource :session

  def create
    @attendance = @session.attendances.build
    @attendance.participant = current_participant
    if @attendance.save
      respond_to do |format|
        format.html do
          flash[:notice] = "Thanks for your interest in this session."
          redirect_to @session
        end

        format.json do
          render :partial => 'sessions/participant', :formats => ['html'], :locals => { :participant => current_participant }
        end
      end
    else
      respond_to do |format|
        format.json do
          render :partial => 'sessions/new_participant', :formats => ['html'], :status => :unprocessable_entity
        end
      end
    end
  end

  private

  def create_participant
    return if logged_in?
    return if params[:attendance].nil?

    name, email, password = params[:attendance][:name], params[:attendance][:email], params[:attendance][:password]

    participant_session = ParticipantSession.new(:email => email, :password => password)
    if participant_session.save
      @current_participant_session = participant_session
    else
      participant = Participant.new(:name => name, :email => email, :password => password)
      if participant.save
        @current_participant_session = ParticipantSession.create(participant, true)
      else
        flash[:error] = "There was a problem creating an account for you. Please try again."
        redirect_to new_participant_path
      end
    end
  end
end
