class ParticipantsController < ApplicationController
  include ParticipantsHelper

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
    unless @participant.email_confirmed?
      flash[:alert] = email_confirmation_alert(@participant)
    end
    respond_with(@participant)
  end

  def edit
    unless @participant.email_confirmed?
      flash[:alert] = email_confirmation_alert(@participant)
    end
    respond_with(@participant)
  end

  def update
    new_params = participant_params.except(:code_of_conduct_agreement)

    # reset email_confirmed_at if the email address was changed
    if (new_params[:email] != @participant.email)
      @participant.email_confirmed_at = nil
    end

    if @participant.update(new_params)
      create_code_of_conduct_agreement_if_not_exists!
      flash[:notice] = "Profile updated successfully."
      redirect_to participant_path(@participant)
    else
      flash[:error] = "There was a problem updating your profile."
      render :edit
    end
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
    redirect_to participant_path(@participant) if @participant != current_participant
  end
end
