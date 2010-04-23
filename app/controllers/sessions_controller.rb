class SessionsController < ApplicationController
  make_resourceful do
    actions :index, :show, :new, :create, :update

    before :create do
      name, email = object_parameters[:name], object_parameters[:email]

      participant = Participant.first(:conditions => {:email => email}) || Participant.create(:email => email, :name => name)
      if !participant.new_record?
        current_object.participant = participant
      end
    end
  end
end
