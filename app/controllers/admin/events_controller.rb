class Admin::EventsController < Admin::AdminController
  make_resourceful do
    actions :index, :create, :new

    response_for :create do
      redirect_to admin_events_path
    end
  end
end
