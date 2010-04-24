class AttendancesController < ApplicationController
  before_filter :create_participant, :only => :create
  
  make_resourceful do
    belongs_to :session
    actions :create

    response_for :create do |format|
      format.html do
        redirect_to @session
      end
      
      format.json do
        render :partial => 'sessions/participant.html.erb', :locals => { :participant => current_participant }
      end
    end

    response_for :create_fails do |format|
      format.json do
        render :template => 'sessions/new_participant.html.erb'
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
    
    name, email = object_parameters[:name], object_parameters[:email]

    participant = Participant.first(:conditions => {:email => email}) || Participant.create(:email => email, :name => name)
      
    if !participant.new_record?
      session[:participant_id] = participant.id
    end
    #FIXME: error messages???
  end
end
