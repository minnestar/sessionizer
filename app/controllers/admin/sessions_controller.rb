class Admin::SessionsController < Admin::AdminController
  make_resourceful do
    actions :index, :edit, :update, :new, :create

    response_for :update do
      redirect_to admin_sessions_path
    end
  end

  def create
    # find exact match by name
    presenter = Participant.find_by_name(params[:session][:name])

    unless presenter
      presenter = Participant.create!(:name => params[:session][:name])
    end

    @session = Event.current_event.sessions.new(params[:session])
    @session.participant = presenter
    @session.timeslot_id = params[:session][:timeslot_id]
    @session.room_id = params[:session][:room_id]
    
    if @session.save!
      flash[:notice] = "Presentation added"
      redirect_to admin_sessions_path
    else
      render :new
    end
  end

  def current_objects
    @current_objects ||= Event.current_event.sessions
  end  
end
