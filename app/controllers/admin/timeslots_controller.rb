class Admin::TimeslotsController < Admin::AdminController
  load_resource :event
  load_resource :timeslot, through: :event

  def index
  end

  def new
  end

  def create
    @timeslot.attributes = timeslot_params
    if @timeslot.save
      redirect_to admin_event_timeslots_path
    else
      render :new
    end
  end

  private

  def timeslot_params
    params.require(controller_name.singularize).permit(:starts_at, :ends_at, :event_id)
  end

end
