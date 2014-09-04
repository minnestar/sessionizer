class Admin::PresentersController < Admin::AdminController
  make_resourceful do
    actions :index, :edit
  end

  def update
    if current_object.update_attributes(params[:participant])
      flash[:success] = "Presenter updated."
      redirect_to admin_presenters_path
    else
      render :edit
    end
  end

  def export
    render text: current_objects.map { |presenter| "\"#{presenter.name}\" <#{presenter.email}>" }.join(",\n"), content_type: Mime::TEXT
  end

  # export a list of all presenters from every event
  def export_all
    participant_ids = Session.all.map(&:presenter_ids)
    render text: Participant.find(participant_ids).map { |presenter| "\"#{presenter.name}\" <#{presenter.email}>" }.join(",\n"), content_type: Mime::TEXT
  end

  private

  def current_objects
    @current_objects ||= Participant.find(Event.current_event.sessions.map(&:presenter_ids))
  end

  def current_model
    Participant
  end
end
