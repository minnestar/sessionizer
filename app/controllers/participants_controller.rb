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
    @participant.update(participant_params.except(:code_of_conduct_agreement))
    create_code_of_conduct_agreement_if_not_exists!
    respond_with(@participant)
  end

  def create
    @participant.attributes = participant_params.except(:code_of_conduct_agreement)
    if @participant.save
      create_code_of_conduct_agreement_if_not_exists!
      flash[:notice] = "Thanks for registering an account. You may now create sessions and mark sessions you'd like to attend."
      redirect_to root_path
    else
      flash[:error] = "There was a problem creating that account."
      render :new
    end
  end

  def create_code_of_conduct_agreement_if_not_exists!
    if participant_params[:code_of_conduct_agreement] == '1' && @participant.signed_code_of_conduct_for_current_event? == false
      CodeOfConductAgreement.create!({
        participant_id: @participant.id,
        event_id: Event.current_event.id,
      })
    end
  end

  private

  def participant_params
    params.require(controller_name.singularize).permit(
      :name, :email, :password,
      :bio, :github_profile_username,
      :twitter_handle, :code_of_conduct_agreement,
      :address
    )
  end

  def verify_owner
    redirect_to @participant if @participant != current_participant
  end
end
