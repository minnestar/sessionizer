class PresentationsController < ApplicationController
  load_resource :session
  load_resource :presentation, through: :session
  respond_to :html

  def index
    @presentation = Presentation.new
    respond_with(@presentations)
  end

  def create
    # super lame: look up the person by name. Twitter's typeahead library doesn't currently have a way to report an item's been selected.

    participant = Participant.where(:name => params[:name]).first

    if participant.nil?
      flash[:error] = "Sorry, no presenter named '#{params[:name]}' was found. Please try again."
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
