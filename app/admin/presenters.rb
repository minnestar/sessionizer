ActiveAdmin.register Participant, as: "Presenter" do
  menu priority: 4

  config.batch_actions = false
  config.sort_order = "first_submitted_at_desc"

  actions :index

  controller do
    before_action :set_default_event_filter, only: :index

    def scoped_collection
      Participant.joins(:presentations)
        .includes(presentations: :session)
        .select("participants.*, MIN(presentations.created_at) AS first_submitted_at")
        .group("participants.id")
    end

    def selected_event_id
      params.dig(:q, :presentations_session_event_id_eq).presence || Event.current_event.id
    end
    helper_method :selected_event_id

    private

    def set_default_event_filter
      return if params[:commit].present? || params[:q].present?

      params[:q] = { presentations_session_event_id_eq: Event.current_event.id.to_s }
    end
  end

  filter :presentations_session_event_id, as: :select,
         label: "Event",
         include_blank: false,
         collection: proc { Event.order(created_at: :desc).map { |e| ["#{e.name} (#{e.date.year})", e.id] } }


  collection_action :export, method: :get do
    sessions = params[:event_id].present? ? Session.where(event_id: params[:event_id]) : Session.all
    presenter_ids = sessions.joins(:presentations)
      .pluck("presentations.participant_id")
      .uniq
    presenters = Participant.where(id: presenter_ids)
      .joins(:presentations)
      .merge(Presentation.where(session_id: sessions.select(:id)))
      .group("participants.id")
      .order(Arel.sql("MIN(presentations.created_at) DESC"))

    render body: presenters.map { |p| "\"#{p.name}\" <#{p.email}>" }.join(",\n"),
           content_type: Mime[:text]
  end

  action_item :export, only: :index do
    link_to "Export presenter emails",
      export_admin_presenters_path(event_id: selected_event_id),
      class: "action-item-button cursor-pointer"
  end

  index download_links: false do
    column :name do |presenter|
      link_to presenter.name, admin_participant_path(presenter)
    end
    column :email
    column("Sessions") do |presenter|
      event_id = controller.selected_event_id.to_i
      presenter.presentations.select { |p| p.session&.event_id == event_id }.map do |p|
        link_to(p.session.title, admin_session_path(p.session))
      end.join(", ").html_safe
    end
    column("Submitted At", sortable: :first_submitted_at) do |presenter|
      presenter.first_submitted_at&.strftime("%-m/%-d/%y")
    end
  end
end
