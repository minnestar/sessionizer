class UserSessionsController < ApplicationController
  def new
    @participant_session = ParticipantSession.new
  end

  def create
    @participant_session = ParticipantSession.new(params[:participant_session])
    if @participant_session.save
      flash[:notice] = "You're logged in. Welcome back."
      redirect_to root_path
    else
      flash.now[:error] = "Sorry, couldn't find that participant. Try again, or sign up to register a new account."
      render :action => :new
    end
  end

  def destroy
    current_participant_session.destroy

    flash[:notice] = 'You have been logged out.'
    redirect_to root_path
  end
end
