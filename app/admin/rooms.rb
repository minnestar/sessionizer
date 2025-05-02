ActiveAdmin.register Room do
  config.filters = false

  belongs_to :event

  permit_params :event_id, :name, :capacity, :schedulable
  config.sort_order = 'capacity_desc'

  # don't allow delete
  actions :all, except: [:destroy]

  # eager load associations on the show page
  controller do
    def scoped_collection
      collection = super
      if action_name == "show"
        collection.includes(sessions: [:timeslot, { presentations: :participant }])
      else
        collection
      end
    end
  end

  index do
    column :id
    column :event
    column :name do |room|
      link_to room.name, admin_event_room_path(room.event, room)
    end
    column :capacity
    column :schedulable
    column("Sessions") do |room|
      link_to(
        "#{room.sessions.size}",
        admin_sessions_path(order: "timeslot_id_asc", q: { event_id_eq: room.event_id, room_id_eq: room.id })
      )
      end
    actions
  end

  show do
    attributes_table do
      row :id
      row :event
      row :name
      row :capacity
      row :schedulable
    end

    panel "Sessions (#{room.sessions.with_canceled.size})" do
      if room.sessions.with_canceled.any?
        table_for room.sessions.with_canceled.order('sessions.timeslot_id') do
          column("Timeslot") do |session|
            link_to session.timeslot.to_s, admin_event_timeslot_path(session.event, session.timeslot)
        end
        column :title do |session|
          (link_to(session.title, admin_session_path(session)) +
          (session.canceled? ? " (CANCELED)" : "")).html_safe
          end
        column :presenters
        column("Votes", &:attendances_count)
        column("Canceled", &:canceled?)
        end
      else
        div do
          "No sessions scheduled in this room."
        end
      end
    end
  end
end
