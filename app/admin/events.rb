ActiveAdmin.register Event do
  permit_params :name, :date

  config.filters = false

  index do
    column :id
    column :name do |event|
      link_to event.name, admin_event_path(event)
    end
    column("# of Sessions") do |event|
      link_to event.sessions.count, admin_sessions_path(q: { event_id_eq: event.id })
    end
    column :date
  end

  show do
    attributes_table do
      row :name
      row :date
      row :timeslots
      row "# of Rooms" do |event|
        event.rooms.count
      end
      row "# of Sessions" do |event|
        event.sessions.count
      end
      row :created_at
      row :updated_at
    end

    panel "Sessions" do
      table_for event.sessions.order(:timeslot_id) do
        column :title do |session|
          link_to session.title, admin_session_path(session)
        end
        column :presenters do |session|
          session.presenters.map { |presenter| link_to presenter.name, admin_participant_path(presenter) }.join(", ").html_safe
        end
        column :timeslot do |session|
          session.timeslot&.to_s
        end
        column :room do |session|
          session.room&.name
        end
      end
    end
  end
  
end
