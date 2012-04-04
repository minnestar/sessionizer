class Admin::SessionsController < Admin::AdminController
  make_resourceful do
    actions :index, :edit, :update

    response_for :update do
      redirect_to admin_sessions_path
    end
  end

  def current_objects
    @current_objects ||= Event.current_event.sessions
  end
  
end
