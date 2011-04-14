class Admin::AdminController < ApplicationController
  before_filter :authenticate

  private

  def authenticate
    if Rails.env.production?
      authenticate_or_request_with_http_basic do |user_name, password|
        user_name == "minnestar" && password == "nottheusualpassword"
      end
    end
  end

end
