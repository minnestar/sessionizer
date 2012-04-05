class EventsController < ApplicationController
  def index
    @events = Event.all
  end

  def show
    @event = Event.find(params[:id], :include => :sessions)
    respond_to do |format|
      format.html
      format.json do
        render :json => @event.to_json(:include => { :sessions => { :methods => [:starts_at, :room_name, :presenter_names] } } )
      end
    end
  end
end
