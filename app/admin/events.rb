ActiveAdmin.register Event do
  menu priority: 1
  permit_params :name, :date

  # Only eager load associations on the show page
  controller do
    def scoped_collection
      collection = super
      if action_name == "show"
        collection.includes(
          sessions: [
            :timeslot,
            :room,
            { presentations: :participant },
            :attendances
          ]
        )
      else
        collection
      end
    end
  end

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
      link_to event.sessions_count, admin_sessions_path(q: { event_id_eq: event.id })
    end
    column("# of Rooms") do |event|
      event.rooms_count
    end
    column("# of Timeslots") do |event|
      event.timeslots_count
    end
  end

  show do
    attributes_table do
      row :name
      row :date
      row :timeslots
      row "# of Rooms" do |event|
        event.rooms_count
      end
      row "# of Sessions" do |event|
        event.sessions_count
      end
      row :created_at
      row :updated_at
    end

    panel "Sessions" do
      table_for event.sessions.includes(presentations: :participant).order(:timeslot_id) do
        column :title do |session|
          link_to session.title, admin_session_path(session)
        end
        column :presenters do |session|
          session.presentations.map do |presentation|
            link_to presentation.participant.name, admin_participant_path(presentation.participant)
          end.join(", ").html_safe
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
