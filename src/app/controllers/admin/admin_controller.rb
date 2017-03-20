class Admin::AdminController < ApplicationController
  before_action :redirect_to_ssl
  before_action :authenticate

  private

  def redirect_to_ssl
    if Rails.env.production? && !request.ssl?
      redirect_to(protocol: 'https://')
    end
  end

  def authenticate
    if Rails.env.production?
      authenticate_or_request_with_http_basic do |user_name, password|
        user_name == ENV['SESSIONIZER_ADMIN_USER'] && password == ENV['SESSIONIZER_ADMIN_PASSWORD']
      end
    end
  end

end
