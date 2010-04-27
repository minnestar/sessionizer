class SessionsController < ApplicationController
  make_resourceful do
    actions :index, :show, :new
  end

  def create
    build_object
    load_object
    
    if logged_in?
      current_object.participant = current_participant
    else
      name, email = object_parameters[:name], object_parameters[:email]

      participant = Participant.first(:conditions => {:email => email}) || Participant.create(:email => email, :name => name)
      
      if !participant.new_record?
        session[:participant_id] = participant.id
        current_object.participant = participant
      else
        current_object.errors.add_to_base("The participant is invalid.") # FIXME: better message
      end
    end

    if verify_recaptcha(:model => current_object, :message => "Please try entering the captcha again.") && current_object.save
      flash[:notice] = "Thanks for adding your session."
      redirect_to current_object
    else
      render :action => 'new'
    end
  end
end
