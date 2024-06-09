class Admin::ConfigsController < Admin::AdminController

  def show
  end

  def create
    settings.show_schedule = params[:show_schedule]
    settings.allow_new_sessions = params[:allow_new_sessions]
    flash[:notice] =  "Configuration saved"
    redirect_to action: :show
  end

  helper_method :settings

  def settings
    Settings
  end
end
