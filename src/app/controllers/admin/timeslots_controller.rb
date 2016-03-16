class Admin::TimeslotsController < Admin::AdminController
  load_resource :event, only: [:index, :new, :create]
  load_resource :timeslot, through: :event, only: [:index, :new, :create]
  load_resource :timeslot, only: [:edit, :update]

  def index
  end

  def new
    # Set some useful defaults
    @timeslot.starts_at = @event.date
    @timeslot.ends_at = @event.date
    @timeslot.title = "Session #{@event.sessions.count + 1}"
  end

  def edit
  end

  def update
    if @timeslot.update timeslot_params
      redirect_to admin_event_timeslots_path(event_id: @timeslot.event_id)
    else
      render :edit
    end
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
    params.require(controller_name.singularize).permit(:starts_at, :ends_at, :event_id, :schedulable, :title)
  end

end
