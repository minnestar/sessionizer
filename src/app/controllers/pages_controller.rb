class PagesController < ApplicationController
  def home
    @current_event = Event.current_event
    @recent_sessions = @current_event ? @current_event.sessions.limit(4).recent : []
    @random_sessions = @current_event ? @current_event.sessions.limit(6).random_order : []

    @categories = Category.all.order('id')
  end
end
