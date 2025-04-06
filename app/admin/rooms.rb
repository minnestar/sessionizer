ActiveAdmin.register Room do
  config.filters = false

  belongs_to :event

  permit_params :event_id, :name, :capacity, :schedulable
  config.sort_order = 'capacity_desc'

  actions :all, except: [:destroy]

  # eager load associations on show page
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

    panel "Sessions" do
      table_for room.sessions.order('sessions.timeslot_id') do
        column("Timeslot") do |session|
          link_to session.timeslot.to_s, admin_event_timeslot_path(session.event, session.timeslot)
        end
        column :title do |session|
          link_to session.title, admin_session_path(session)
        end
        column :presenters
      end
    end
  end
end
