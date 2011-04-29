class UserSessionsController < ApplicationController
  def new
    @participant = Participant.new
  end

  def create
    @participant = Participant.first(:conditions => ['lower(email) = ?', params[:participant][:email].downcase])

    if !verify_recaptcha
      @participant = Participant.new(:email => params[:participant][:email])
      flash[:error] = "Sorry, your recaptcha response wasn't reccognized. Please try again."
      render :action => 'new'
      return
    end

    if @participant
      session[:participant_id] = @participant.id
      flash[:notice] = "You're logged in. Welcome back."
      redirect_to root_path
    else
      @participant = Participant.new(:email => params[:participant][:email])
      flash[:error] = "Sorry, couldn't find that participant. Try again, or sign up to attend a session to register a new account."
      render :action => 'new'
    end
  end
end
