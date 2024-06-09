class PresentationsController < ApplicationController
  load_resource :session
  load_resource :presentation, through: :session
  respond_to :html

  def index
    @presentation = Presentation.new
    respond_with(@presentations)
  end

  def create
    begin
      participant = if participant_params[:id].present?
        Participant.find(participant_params[:id])
      elsif participant_params[:name].present?
        participant = Participant.where(name: participant_params[:name])&.first
      end

      if participant.nil?
        flash[:error] = "Sorry, no presenter #{participant_params[:name] ? "matching '#{participant_params[:name]}' " : "" }was found. Please try again."
        redirect_to session_presentations_path(@session)
        return
      elsif participant.signed_code_of_conduct_for_current_event? == false
        flash[:error] = "Sorry, #{participant.name} hasn't signed the current Code of Conduct."
        redirect_to session_presentations_path(@session)
        return
      end

      presentation = @session.presentations.new
      presentation.participant = participant

      if presentation.save
        flash[:notice] = "Presenter added."
        redirect_to session_presentations_path(@session)
      else
        raise StandardError
      end
    rescue => e
      flash[:error] = "There was an error adding the presenter. Please try again. If this keeps happening, please contact support@minnestar.org."
      redirect_to session_presentations_path(@session)
    end
  end

  private

  def participant_params
    params.permit(:session_id, :id, :name)
  end
end
