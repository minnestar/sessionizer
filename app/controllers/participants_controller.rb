class ParticipantsController < ApplicationController
  before_filter :verify_owner, :only => [:edit, :update]
  
  make_resourceful do
    actions :index, :new, :create, :show, :edit, :update

    response_for :index do |format|
      format.json do
        render :json => current_objects.map { |p| {:value => p.name, :tokens => p.name.split(" "), :id => p.id} }
      end
    end

    response_for :create do
      flash[:notice] = "Thanks for registering an account. You may now create sessions and mark sessions you'd like to attend."
      redirect_to root_path
    end
  end

  private

  def verify_owner
    if current_object != current_participant
      redirect_to current_object
    end
  end
end
