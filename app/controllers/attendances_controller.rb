class AttendancesController < ApplicationController
  make_resourceful do
    belongs_to :session
    actions :create

    response_for :create do |format|
      format.json do
        render :partial => 'sessions/participant.html.erb', :locals => { :participant => current_participant }
      end
    end

  end

  private

  def build_object
    @current_object ||= parent_object.attendances.build(:participant => current_participant)
  end
end
