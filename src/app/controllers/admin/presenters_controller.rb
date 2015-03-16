class Admin::PresentersController < Admin::AdminController
  before_filter :load_presenters, only: [:index, :export]
  load_resource class: 'Participant'
  respond_to :html

  def index
    respond_with(@presenters)
  end

  def edit
    respond_with(@presenter)
  end

  def update
    if @presenter.update(presenter_params)
      flash[:success] = "Presenter updated."
      redirect_to admin_presenters_path
    else
      render :edit
    end
  end

  def export
    render text: @presenters.map { |presenter| "\"#{presenter.name}\" <#{presenter.email}>" }.join(",\n"), content_type: Mime::TEXT
  end

  # export a list of all presenters from every event
  def export_all
    participant_ids = Session.all.map(&:presenter_ids)
    render text: Participant.find(participant_ids).map { |presenter| "\"#{presenter.name}\" <#{presenter.email}>" }.join(",\n"), content_type: Mime::TEXT
  end

  private

  def presenter_params
    params.require(:participant).permit(:name, :email, :bio)
  end


  def load_presenters
    @presenters ||= Participant.find(Event.current_event.sessions.map(&:presenter_ids))
  end

end
