class PagesController < ApplicationController
  def home
    @current_event = Event.current_event
    @recent_sessions = @current_event ? @current_event.sessions.limit(10).order('created_at desc') : []

    @categories = Category.all.order('id')
  end
end
