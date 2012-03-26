class Admin::TimeslotsController < Admin::AdminController
  make_resourceful do
    actions :index, :create, :new
    belongs_to :event

    response_for :create do
      redirect_to admin_events_path
    end
  end
end
