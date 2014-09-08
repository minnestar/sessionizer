class Admin::SessionsController < Admin::AdminController
  before_filter :load_sessions, only: :index
  before_filter :build_presenter, only: :create
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
    if @session.update_attributes(params[:session], :without_protection => true)
      redirect_to admin_sessions_path
    else
      render :edit
    end
  end

  def build_presenter
    name = params[:session].delete(:name)
    # find exact match by name
    @presenter = Participant.first_or_initialize(name: name).tap do |p|
      p.save(validate: false) if p.new_record?
    end
  end

  def create
    @session.event = Event.current_event
    @session.participant = @presenter
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

  def load_sessions
    @sessions ||= Event.current_event.sessions.sort_by{ |s| -s.created_at.to_i}
  end
end
