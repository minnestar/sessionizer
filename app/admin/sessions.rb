ActiveAdmin.register Session do
  menu priority: 2

  controller do
    def scoped_collection
      Session.unscoped
    end
  end

  scope :all
  scope :active, default: true
  scope :canceled

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
    :manual_attendance_estimate,
    :canceled_at
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

  filter :event, as: :select, collection: proc { Event.order(created_at: :desc).map { |e| [e.name + " (" + e.date.year.to_s + ")", e.id] } }
  filter :title
  filter :participant_id, as: :select,
         label: 'Creator',
         collection: proc { Participant.with_sessions.distinct.order(:name).pluck(:name, :id) }

  member_action :cancel, method: :post do
    resource.update!(canceled_at: Time.current)
    redirect_to admin_session_path(resource), notice: "Session has been canceled"
  end

  member_action :uncancel, method: :post do
    resource.update!(canceled_at: nil)
    redirect_to admin_session_path(resource), notice: "Session has been uncanceled"
  end

  action_item :cancel, only: :show do
    link_to(
      'Cancel Session',
      cancel_admin_session_path(resource),
      method: :post,
      data: { confirm: "Are you sure you want to cancel this session?" }
    ) if !resource.canceled? && resource.event_id == Event.current_event.id
  end

  action_item :uncancel, only: :show do
    link_to('Uncancel Session', uncancel_admin_session_path(resource), method: :post) if resource.canceled?
  end

  index do
    column :id
    column :title do |session|
      (link_to(session.title, admin_session_path(session)) +
       (session.canceled? ? " (CANCELED)" : "")).html_safe
    end
    column("Presenters") do |session|
      session.presenters.map do |presenter|
        link_to presenter.name, admin_participant_path(presenter)
      end.join(", ").html_safe
    end
    column("Event", sortable: 'events.date') do |session|
      (link_to(session.event.name, admin_event_path(session.event)) + " (#{session.event.date.year})").html_safe if session.event
    end
    column("Votes", sortable: :attendances_count, &:attendances_count)
    column :timeslot, sortable: :timeslot
    column :room, sortable: :room
    column("Canceled", &:canceled?)
    column("Created", sortable: :created_at) do |session|
      session.created_at.strftime("%-m/%-d/%y")
    end
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
        session.attendances_count
      end
      row :timeslot
      row :room
      row :manually_scheduled
      row :canceled?
      row :canceled_at
      row :created_at
      row :updated_at
    end

    panel "Interested Participants (#{session.attendances_count})" do
      table_for session.attendances.includes(:participant).order('created_at desc') do
        column :name do |attendance|
          link_to attendance.participant.name, admin_participant_path(attendance.participant)
        end
        column :email_confirmed do |attendance|
          attendance.participant.email_confirmed?
        end
        column :created do |attendance|
          attendance.created_at.strftime("%-m/%-d/%y")
        end
      end
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
