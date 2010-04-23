# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  helper :layout
  helper_method :current_user
  helper_method :logged_in?
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  def current_participant
    @current_user ||= Participant.find_by_id(session[:participant_id])
  end

  def logged_in?
    session[:participant_id] && !current_participant.nil?
  end
end
