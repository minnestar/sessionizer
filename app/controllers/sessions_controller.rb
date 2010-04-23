class SessionsController < ApplicationController
  make_resourceful do
    actions :index, :show, :new, :create, :update

    before :create do
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
    end
  end
end
