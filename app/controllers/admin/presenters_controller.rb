class Admin::PresentersController < Admin::AdminController
  make_resourceful do
    actions :index, :edit, :show
  end

  def export
    render :text => current_objects.map { |presenter| "\"#{presenter.name}\" <#{presenter.email}>" }.join(",\n"), :content_type => Mime::TEXT
  end

  def export_all
    participant_ids = Session.all.map(&:participant_id)
    render :text => Participant.find(participant_ids).map { |presenter| "\"#{presenter.name}\" <#{presenter.email}>" }.join(",\n"), :content_type => Mime::TEXT
  end

  private

  def current_objects
    @current_objects ||= Participant.find(Event.current_event.sessions.map(&:participant_id)) # isn't sessions.participant_ids supposed to work?
  end

  def current_model
    Participant
  end
end
