class ParticipantsController < ApplicationController
  respond_to :html
  load_resource except: :confirm_email
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
    # TODO: Check if email address was changed. If so, clear out email_confirmed_at
    @participant.update(participant_params.except(:code_of_conduct_agreement))
    create_code_of_conduct_agreement_if_not_exists!
    respond_with(@participant)
  end

  def create
    @participant.attributes = participant_params.except(:code_of_conduct_agreement)
    if @participant.save
      create_code_of_conduct_agreement_if_not_exists!
      @participant.deliver_email_confirmation_instructions!
      flash[:notice] = "Thanks for registering an account. Please check your email to confirm your account."
      redirect_to root_path
    else
      flash[:error] = "There was a problem creating your account."
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

  def send_confirmation_email
    @participant.deliver_email_confirmation_instructions!
    flash[:notice] = "Confirmation instructions sent! Please check your email."
    redirect_to @participant
  end

  def confirm_email
    # TODO: load participant by perishable token
    @participant = Participant.find_using_perishable_token(params[:token])
    if @participant.confirm_email!
      flash[:notice] = "Email confirmed. Thank you!"
      redirect_to root_path
    else
      flash[:error] = "Something went wrong. Please try again."
      redirect_to root_path
    end
  end

  private

  def participant_params
    params.require(controller_name.singularize).permit(
      :name, :email, :password,
      :bio, :github_profile_username,
      :twitter_handle, :code_of_conduct_agreement
    )
  end

  def verify_owner
    redirect_to @participant if @participant != current_participant
  end
end
