ActiveAdmin.register Session do
  menu priority: 2

  permit_params(
    :participant_id,
    :title,
    :description,
    :event_id,
    :timeslot_id,
    :room_id,
    :summary,
    :level_id,
    :manually_scheduled,
    :manual_attendance_estimate
  )

  includes [
    :attendances,
    :presenters,
    :event,
    :participant,
    :level,
    :categories,
    :timeslot,
    :room
  ]

  filter :event
  filter :title
  filter :participant_id, as: :select,
         label: 'Creator',
         collection: proc { Participant.with_sessions.distinct.order(:name).pluck(:name, :id) }

  index do
    column :id
    column :title do |session|
      link_to session.title, admin_session_path(session) + (session.canceled? ? " (CANCELED)" : "")
    end
    column("Presenters") do |session|
      session.presenters.map do |presenter|
        link_to presenter.name, admin_participant_path(presenter)
      end.join(", ").html_safe
    end
    column("Event") do |session|
      (link_to(session.event.name, admin_event_path(session.event)) + " (#{session.event.date.year})").html_safe if session.event
    end
    column("Votes") do |session|
      session.attendances.size
    end
    column :timeslot
    column :room
  end

  show  title: :title do
    attributes_table do
      row :event do |session|
        (link_to(session.event.name, admin_event_path(session.event)) + " (#{session.event.date.year})").html_safe if session.event
      end 
      row :title
      row :participant
      row :presenters
      row :description
      row :level
      row :categories
      row("Votes") do |session|
        session.attendances.size
      end
      row :timeslot
      row :room
      row :manually_scheduled
      row :canceled?
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs do
      f.input :title
      f.input :description
      f.input :participant
      f.input :presenters
      f.input :level
      f.input :categories
      f.input :timeslot
      f.input :room
      f.input :manually_scheduled
    end
    f.actions
  end
end
