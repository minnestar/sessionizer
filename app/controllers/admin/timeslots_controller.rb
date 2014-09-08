class Admin::TimeslotsController < Admin::AdminController
  load_resource :event
  load_resource :timeslot, through: :event, except: :create

  def index
  end

  def new
  end

  def create
    @timeslot = Timeslot.new(params[:timeslot], :without_protection => true)
    if @timeslot.save
      redirect_to admin_event_timeslots_path
    else
      render :new
    end
  end

end
