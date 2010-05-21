class SessionsController < ApplicationController
  before_filter :verify_owner, :only => [:update, :edit]
  
  make_resourceful do
    actions :index, :show, :new, :edit, :update
  end

  # def create
  #   build_object
  #   load_object
    
  #   if logged_in?
  #     current_object.participant = current_participant
  #   else
  #     name, email = object_parameters[:name], object_parameters[:email]

  #     participant = Participant.first(:conditions => {:email => email}) || Participant.create(:email => email, :name => name)
      
  #     if !participant.new_record?
  #       session[:participant_id] = participant.id
  #       current_object.participant = participant
  #     else
  #       current_object.errors.add_to_base("The participant is invalid.") # FIXME: better message
  #     end
  #   end

  #   if verify_recaptcha(:model => current_object, :message => "Please try entering the captcha again.") && current_object.save
  #     flash[:notice] = "Thanks for adding your session."
  #     redirect_to current_object
  #   else
  #     render :action => 'new'
  #   end
  # end

  def words
    @sessions = Session.all
  end

  def export
    @sessions = Session.all(:order => 'lower(title) asc')
    render :layout => 'export'
  end

  def popularity
    @sessions = Session.with_attendence_count.all(:order => "COALESCE(attendence_count, 0) desc")
    render :layout => 'export'
  end

  private

  def verify_owner
    if current_object.participant != current_participant
      redirect_to current_object
    end
  end
end
