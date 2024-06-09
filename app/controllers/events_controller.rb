class EventsController < ApplicationController
  def show
    @event = if params[:id] == 'current'
      Event.current_event
    else
      Event.find(params[:id])
    end

    respond_to do |format|
      format.html do
        @recent_sessions = @event ? @event.sessions.limit(4).recent : []
        @random_sessions = @event ? @event.sessions.limit(6).random_order : []

        @categories = Category.all.order('id')
      end

      format.json do
        render json: @event.to_json(include: { sessions: { methods: [:starts_at, :room_name, :presenter_names] } })
      end
    end
  end
end
