ActiveAdmin.register Timeslot do
  config.filters = false

  belongs_to :event

  permit_params :event_id, :starts_at, :ends_at, :schedulable, :title
  config.sort_order = 'starts_at_asc'

  includes :sessions

  # don't allow delete or new
  actions :all, except: [:destroy, :new]

  action_item :generate_timeslots, only: [:index] do
    event = Event.find(params[:event_id])
    if event.timeslots_count.zero?
      link_to 'Generate timeslots',
        generate_timeslots_admin_event_path(event),
        method: :post,
        data: { confirm: "This will generate #{Settings.default_timeslots.size} timeslots based on the defaults in Event Settings. Are you sure you want to proceed?" }
    end
  end

  index do
    column :id
    column :event
    column :title do |timeslot|
      link_to timeslot.title, admin_event_timeslot_path(timeslot.event, timeslot)
    end
    column(:display, &:to_s)
    column :schedulable
    column("Sessions", sortable: :sessions_count) do |timeslot|
      link_to(
        timeslot.sessions.size,
        admin_sessions_path(order: "attendances_count_desc", q: { event_id_eq: timeslot.event_id, timeslot_id_eq: timeslot.id })
      )
    end
  end

  show do
    attributes_table do
      row :id
      row :event
      row :title
      row :starts_at
      row :ends_at
      row(:display, &:to_s)
      row :schedulable
    end

    panel "Sessions (#{timeslot.sessions.with_canceled.size})" do
      if timeslot.sessions.with_canceled.any?
        table_for timeslot.sessions.with_canceled.order('sessions.attendances_count DESC') do
          column :title do |session|
            (link_to(session.title, admin_session_path(session)) +
            (session.canceled? ? " (CANCELED)" : "")).html_safe
          end
          column :presenters
          column :room
          column("Votes", &:attendances_count)
          column("Canceled", &:canceled?)
        end
      else
        div do
          "No sessions scheduled during this timeslot."
        end
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :event, as: :select, input_html: { disabled: true }
      f.input :title
      f.input :starts_at
      f.input :ends_at
      f.input :schedulable
    end
    f.actions
  end
end
