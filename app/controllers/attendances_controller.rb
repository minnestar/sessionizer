class AttendancesController < ApplicationController
  before_filter :create_participant, :only => :create
  
  make_resourceful do
    belongs_to :session
    actions :create

    response_for :create do |format|
      format.html do
        flash[:notice] = "Thanks for your interest in this session."
        redirect_to @session
      end
      
      format.json do
        render :partial => 'sessions/participant', :formats => ['html'], :locals => { :participant => current_participant }
      end
    end

    response_for :create_fails do |format|
      format.json do
        render :partial => 'sessions/new_participant', :formats => ['html'], :status => :unprocessable_entity
      end
    end
  end

  private

  def build_object
    @current_object ||= parent_object.attendances.build(:participant => current_participant)
  end

  def create_participant
    return if logged_in?
    return if object_parameters.nil?

    name, email, password = object_parameters[:name], object_parameters[:email], object_parameters[:password]

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
