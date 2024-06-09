class Admin::RoomsController < Admin::AdminController
  load_resource :event, only: [:new, :create]
  load_resource :room, through: :event, only: [:new, :create]
  load_resource :room, only: [:edit, :update]

  def new
  end

  def edit
  end

  def update
    if @room.update room_params
      redirect_to admin_event_path(@room.event_id)
    else
      render :edit
    end
  end

  def create
    @room.attributes = room_params
    if @room.save
      redirect_to admin_event_path(@event)
    else
      render :new
    end
  end

  private

  def room_params
    params.require(controller_name.singularize).permit(:name, :capacity)
  end

end
