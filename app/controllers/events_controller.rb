class EventsController < ApplicationController
  def show
    @event = Event.includes(:sessions).find(params[:id])

    respond_to do |format|
      format.json do
        render json: @event.to_json(include: { sessions: { methods: [:starts_at, :room_name, :presenter_names] } })
      end
    end
  end
end
