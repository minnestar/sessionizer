class Admin::SessionsController < Admin::AdminController
  make_resourceful do
    actions :index, :edit, :update

    response_for :update do
      redirect_to admin_sessions_path
    end
  end
  
end
