class ParticipantsController < ApplicationController
  before_filter :verify_owner, :only => [:edit, :update]
  before_filter :check_captcha, :only => [:update]
  
  make_resourceful do
    actions :show, :edit, :update
  end

  private

  def check_captcha
    load_object
    if !verify_recaptcha(:model => current_object, :message => "Please try entering the captcha again.")
      render :action => 'edit'
    end
  end
  
  def verify_owner
    if current_object != current_participant
      redirect_to current_object
    end
  end
end
