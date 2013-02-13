class Admin::AdminController < ApplicationController
  before_filter :redirect_to_ssl
  before_filter :authenticate

  private

  def redirect_to_ssl
    if Rails.env.production? && !request.ssl?
      redirect_to "https://sessionizer.heroku.com/admin/sessions/new"
    end
  end

  def authenticate
    if Rails.env.production?
      authenticate_or_request_with_http_basic do |user_name, password|
        user_name == ENV['sessionizer_admin_user'] && password == ENV['sessonizer_admin_password']
      end
    end
  end

end
