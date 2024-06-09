class PresentationsController < ApplicationController
  load_resource :session
  load_resource :presentation, through: :session
  respond_to :html

  def index
    @presentation = Presentation.new
    respond_with(@presentations)
  end

  def create
    participant = Participant.find(params[:id])

    if participant.nil?
      flash[:error] = "Sorry, no presenter named #{params[:name]} was found. Please try again."
      redirect_to session_presentations_path(@session)
      return
    elsif participant.signed_code_of_conduct_for_current_event? == false
      flash[:error] = "Sorry, #{params[:name]} hasn't signed the current Code of Conduct."
      redirect_to session_presentations_path(@session)
      return
    end

    presentation = @session.presentations.new
    presentation.participant = participant

    if presentation.save
      flash[:notice] = "Presenter added."
      redirect_to session_presentations_path(@session)
    else
      flash[:error] = "There was an error adding the presenter. Please try again. If this keeps happening, please contact luke@minnestar.org."
      redirect_to session_presentations_path(@session)
    end
  end
end
