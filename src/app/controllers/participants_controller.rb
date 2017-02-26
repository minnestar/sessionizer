class ParticipantsController < ApplicationController
  respond_to :html
  load_resource
  before_action :verify_owner, :only => [:edit, :update]

  def index
    respond_to do |format|
      format.json do
        render :json => @participants.map { |p| {:value => p.name, :tokens => p.name.split(" "), :id => p.id} }
      end
    end
  end

  def new
    respond_with(@participant)
  end

  def show
    respond_with(@participant)
  end

  def edit
    respond_with(@participant)
  end

  def update
    @participant.update(participant_params)
    respond_with(@participant)
  end

  def create
    @participant.attributes = participant_params
    if @participant.save
      flash[:notice] = "Thanks for registering an account. You may now create sessions and mark sessions you'd like to attend."
      redirect_to root_path
    else
      flash[:error] = "There was a problem creating that account." 
      render :new
    end

  end

  private

  def participant_params
    params.require(controller_name.singularize).permit(:name, :email, :password,
                                                       :bio, :github_profile_username,
                                                       :twitter_handle)
  end

  def verify_owner
    redirect_to @participant if @participant != current_participant
  end
end
