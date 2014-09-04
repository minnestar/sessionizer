class Admin::TimeslotsController < Admin::AdminController
  make_resourceful do
    actions :index, :new
    belongs_to :event
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
