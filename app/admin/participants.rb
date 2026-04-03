ActiveAdmin.register Participant do
  menu priority: 3

  config.batch_actions = false

  permit_params :name, :email, :bio, :email_confirmed_at

  includes :attendances, { presentations: { session: :event } }

  filter :name
  filter :email
  filter :bio
  filter :email_confirmed_at_not_null, as: :boolean,
         label: 'Email confirmed',
         filters: [:eq],
         input_html: { name: 'q[email_confirmed_at_not_null]' }

  index do
    column :name do |participant|
      link_to participant.name, admin_participant_path(participant)
    end
    column :email
    column(:confirmed, &:email_confirmed?)
    column("Sessions", sortable: :presentations_count, &:presentations_count)
    column("Votes", sortable: :attendances_count, &:attendances_count)
    column(:created, sortable: :created_at) { |p| p.created_at.strftime("%-m/%-d/%y") }
  end

  show do
    attributes_table do
      row :name
      row :email
      row :bio do |participant|
        admin_markdown(participant.bio)
      end
      row("Presentations", &:presentations_count)
      row("Attendances", &:attendances_count)
      row("Email confirmed") do |p|
        status_tag p.email_confirmed? ? "Yes" : "No", class: p.email_confirmed? ? :ok : :error
      end
      row :email_confirmed_at
      row :created_at
    end

    panel "Presentations (#{participant.presentations_count})" do
      presented_sessions = Session.with_canceled
        .joins(:presentations)
        .includes(:event)
        .where(presentations: { participant_id: participant.id })
        .order("presentations.created_at DESC")
      table_for presented_sessions do
        column(:title) do |session|
          (link_to(session.title, admin_session_path(session)) +
           (session.canceled? ? " (CANCELED)" : "")).html_safe
        end
        column(:event) do |session|
          if session.event
            (link_to(session.event.name, admin_event_path(session.event)) + " (#{session.event.date.year})").html_safe
          end
        end
      end
    end

    panel "Interested Sessions (#{participant.attendances_count})" do
      interested_sessions = Session.with_canceled
        .joins(:attendances)
        .includes(:event)
        .where(attendances: { participant_id: participant.id })
        .order("events.date DESC, sessions.title")
      table_for interested_sessions do
        column(:title) do |session|
          (link_to(session.title, admin_session_path(session)) +
           (session.canceled? ? " (CANCELED)" : "")).html_safe
        end
        column(:event) do |session|
          if session.event
            (link_to(session.event.name, admin_event_path(session.event)) + " (#{session.event.date.year})").html_safe
          end
        end
        column(:created_at) do |session|
          session.attendances.find_by(participant_id: participant.id)&.created_at&.strftime("%-m/%-d/%y")
        end
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :email
      f.input :bio
    end
    f.actions
  end
end
