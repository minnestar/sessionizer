class Admin::SessionsController < ApplicationController
  before_filter :authenticate

  make_resourceful do
    actions :index, :edit, :update

    response_for :update do
      redirect_to admin_sessions_path
    end
  end
  
  private

  def authenticate
    if Rails.env.production?
      authenticate_or_request_with_http_basic do |user_name, password|
        user_name == "minnestar" && password == "nottheusualpassword"
      end
    end
  end
end
