class Admin::ConfigsController < Admin::AdminController

  def show
  end

  def create
    settings.show_schedule = params[:show_schedule]
    flash[:notice] =  "Configuration saved"
    redirect_to action: :show
  end

  helper_method :settings

  def settings
    Settings
  end
end
