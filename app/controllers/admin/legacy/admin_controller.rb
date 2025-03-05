class Admin::Legacy::AdminController < ApplicationController
  before_action :redirect_to_ssl
  before_action :authenticate_admin  # in ApplicationController

  private

  def redirect_to_ssl
    if Rails.env.production? && !request.ssl?
      redirect_to(protocol: 'https://')
    end
  end

end
