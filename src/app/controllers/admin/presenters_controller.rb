class Admin::PresentersController < Admin::AdminController
  before_action :load_presenters, only: [:index, :export]
  load_resource class: 'Participant'
  respond_to :html

  def index
    respond_with(@presenters)
  end

  def edit
    respond_with(@presenter)
  end

  def update
    # We may only want to update the name here but leave the email address blank
    # so skip validations.  This presenter may have been created by
    # Admin::SessionsController, which does not set an email address.
    @presenter.attributes = presenter_params
    @presenter.save(validate: false)
    flash[:success] = "Presenter updated."
    redirect_to admin_presenters_path
  end

  def export
    render body: @presenters.map { |presenter| "\"#{presenter.name}\" <#{presenter.email}>" }.join(",\n"), content_type: Mime[:text]
  end

  # export a list of all presenters from every event
  def export_all
    participant_ids = Session.all.map(&:presenter_ids)
    render body: Participant.find(participant_ids).map { |presenter| "\"#{presenter.name}\" <#{presenter.email}>" }.join(",\n"), content_type: Mime[:text]
  end

  private

  # Cast blank values to nil (e.g. 'email' => '') because this trips a uniqueness
  # constraint in the database.
  def presenter_params
    params.require(:participant).permit(:name, :email, :bio).to_h.each_with_object({}) do |(k, v), h|
      h[k] = v.blank? ? nil : v
    end
  end


  def load_presenters
    @presenters ||= Participant.find(Event.current_event.sessions.map(&:presenter_ids))
  end

end
