class ParticipantsController < ApplicationController
  before_filter :verify_owner, :only => [:edit, :update]
  
  make_resourceful do
    actions :show, :edit, :update
  end

  private

  def verify_owner
    if current_object != current_participant
      redirect_to current_object
    end
  end
end
