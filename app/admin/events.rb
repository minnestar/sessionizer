ActiveAdmin.register Event do
  menu priority: 1
  permit_params :name, :date

  includes :rooms, :timeslots, {
    sessions: [
      :attendances,
      :presenters,
      :timeslot,
      :room
    ]
  }

  config.filters = false

  # don't allow delete
  actions :all, except: [:destroy]

  index do
    column :id
    column :name do |event|
      link_to event.name, admin_event_path(event)
    end
    column :date
    column("# of Sessions") do |event|
      link_to event.sessions.size, admin_sessions_path(q: { event_id_eq: event.id })
    end
    column("# of Rooms") do |event|
      event.rooms.size
    end
    column("# of Timeslots") do |event|
      event.timeslots.size
    end
  end

  show do
    attributes_table do
      row :name
      row :date
      row :timeslots
      row "# of Rooms" do |event|
        event.rooms.size
      end
      row "# of Sessions" do |event|
        event.sessions.size
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
        column("Votes") do |session|
          session.attendances.size
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
