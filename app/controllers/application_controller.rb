# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  helper :layout
  helper_method :current_participant
  helper_method :logged_in?
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  def current_participant
    @current_participant ||= (current_participant_session && current_participant_session.participant)
  end
  alias_method :current_user, :current_participant

  def current_participant_session
    return @current_participant_session if defined?(@current_participant_session)
    @current_participant_session = ParticipantSession.find
  end

  def logged_in?
    current_participant_session.present?
  end

  def authenticate_participant
    unless logged_in?
      flash[:notice] = 'You must be logged in to do that. Please log in or create a new account and try again.'
      redirect_to new_login_path
    end
  end

  def event_from_params(includes: {})
    query_base = Event
    query_base = query_base.includes(**includes) unless includes.empty?
    if params[:event_id].blank? || params[:event_id] == 'current'
      query_base.current_event
    else
      query_base.find(params[:event_id])
    end
  end

  def event_schedule_cache_key(event)
    [
      event,
      event.sessions,
      event.participants,
      event.timeslots,
      event.rooms,
    ].map(&:cache_key)
  end
  helper_method :event_schedule_cache_key

  def authenticate_admin
    if Rails.env.production?
      authenticate_or_request_with_http_basic do |user_name, password|
        user_name == ENV['SESSIONIZER_ADMIN_USER'] && password == ENV['SESSIONIZER_ADMIN_PASSWORD']
      end
    end
  end
end
