class Admin::SessionsController < Admin::AdminController
  before_action :load_sessions, only: :index
  load_resource
  respond_to :html

  def index
    respond_with(@sessions)
  end

  def edit
    respond_with(@session)
  end

  def new
    respond_with(@session)
  end

  def update
    if @session.update(session_params)
      redirect_to admin_sessions_path
    else
      render :edit
    end
  end

  def build_presenter
    name = params[:session].delete(:name)
    # find exact match by name
    Participant.where(name: name).first_or_initialize do |p|
      p.save(validate: false) if p.new_record?
    end
  end

  def create
    @session.participant = build_presenter
    @session.attributes = session_params
    @session.event = Event.current_event
    @session.timeslot_id = params[:session][:timeslot_id]
    @session.room_id = params[:session][:room_id]

    if @session.save
      flash[:notice] = "Presentation added"
      redirect_to admin_sessions_path
    else
      render :new
    end
  end

  private

  def session_params
    params.require(controller_name.singularize).permit(:title, :description, :summary, :level_id, :room_id, :timeslot_id, :category_ids => [])
  end

  def load_sessions
    @sessions ||= Event.current_event.sessions.includes(:timeslot).order('timeslots.starts_at asc')
  end
end
