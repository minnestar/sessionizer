class Admin::EventsController < Admin::AdminController
  load_resource
  respond_to :html

  def index
    respond_with(@events)
  end

  def new
    respond_with(@event)
  end

  def create
    @event.save!
    redirect_to admin_events_path
  end

  private

  def event_params
    params.require(controller_name.singularize).permit(:name, :date)
  end

end
