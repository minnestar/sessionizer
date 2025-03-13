class Admin::Legacy::SessionsController < Admin::Legacy::AdminController
  before_action :load_sessions, only: :index
  load_resource
  respond_to :html

  def index
    respond_with(@sessions)
  end

  def edit
    respond_with(@session)
  end

  def update
    if @session.update(session_params)
      redirect_to admin_legacy_sessions_path
    else
      render :edit
    end
  end

  def destroy
    @session.destroy!
    flash[:notice] = "Session has been deleted"
    redirect_to '/admin/legacy/sessions'
  end

  private

  def session_params
    params.require(controller_name.singularize).permit(:title, :description, :summary, :level_id, :room_id, :timeslot_id, :category_ids => [])
  end

  def load_sessions
    @sessions ||= Event.current_event.sessions.includes(:timeslot).order('timeslots.starts_at asc')
  end
end
