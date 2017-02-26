class PasswordResetsController < ApplicationController
  # Method from: http://github.com/binarylogic/authlogic_example/blob/master/app/controllers/application_controller.rb
  before_action :load_participant_using_perishable_token, :only => [ :edit, :update ]

  def new
  end

  def create
    @participant = Participant.find_by_email(params[:email])
    if @participant
      @participant.deliver_password_reset_instructions!
      flash[:notice] = "Instructions to reset your password have been emailed to you"
      redirect_to root_path
    else
      flash.now[:error] = "No participant was found with email address #{params[:email]}"
      render :action => :new
    end
  end

  def edit
  end

  def update
    @participant.password = params[:password]
    # Only if your are using password confirmation
    # @participant.password_confirmation = params[:password]

    # Use @participant.save_without_session_maintenance instead if you
    # don't want the participant to be signed in automatically.
    if @participant.save
      flash[:success] = "Your password was successfully updated"
      redirect_to @participant
    else
      render :action => :edit
    end
  end


  private

  def load_participant_using_perishable_token
    @participant = Participant.find_using_perishable_token(params[:id])
    unless @participant
      flash[:error] = "We're sorry, but we could not locate your account"
      redirect_to root_url
    end
  end
end
