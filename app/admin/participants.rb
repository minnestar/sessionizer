ActiveAdmin.register Participant do
  menu priority: 3

  permit_params :name, :email, :bio, :github_profile_username, :github_og_image, :github_og_url, :twitter_handle, :email_confirmed_at

  includes :attendances, { presentations: { session: :event } }

  filter :name
  filter :email
  filter :bio
  filter :email_confirmed_at_not_null, as: :boolean,
         label: 'Email confirmed',
         filters: [:eq],
         input_html: { name: 'q[email_confirmed_at_not_null]' }

  index do
    column :id
    column :name do |participant|
      link_to participant.name, admin_participant_path(participant)
    end
    column :email
    column :bio do |participant|
      truncate(participant.bio, length: 80)
    end
    column(:confirmed, &:email_confirmed?)
    column(:sessions) { |p| p.presentations.size }
    column(:votes) { |p| p.attendances.size }
    column(:created, sortable: :created_at) { |p| p.created_at.strftime("%-m/%-d/%y") }
    actions
  end

  show do
    attributes_table do
      row :name
      row :email
      row :bio do |participant|
        markdown participant.bio
      end
      row(:presentation_count) { |p| p.presentations.size }
      row(:attendance_count) { |p| p.attendances.size }
      row("Email confirmed") do |p|
        status_tag p.email_confirmed? ? "Yes" : "No", class: p.email_confirmed? ? :ok : :error
      end
      row :email_confirmed_at
      row :created_at
    end

    panel "Presentations" do
      table_for participant.presentations.order(created_at: :desc) do
        column(:title) do |p|
          (link_to(p.session.title, admin_session_path(p.session)) +
           (p.session.canceled? ? " (CANCELED)" : "")).html_safe
        end
        column(:event) do |p|
          (link_to(p.session.event.name, admin_event_path(p.session.event)) + " (#{p.session.event.date.year})").html_safe if p.session.event
        end
      end
    end

    panel "Interested Sessions (attendances)" do
      table_for participant.attendances.includes(session: :event).order('events.date desc, sessions.title') do
        column(:title) do |attendance|
          (link_to(attendance.session.title, admin_session_path(attendance.session)) +
           (attendance.session.canceled? ? " (CANCELED)" : "")).html_safe
        end
        column(:event) do |attendance|
          (link_to(attendance.session.event.name, admin_event_path(attendance.session.event)) +
           " (#{attendance.session.event.date.year})").html_safe if attendance.session.event
        end
        column(:created_at) { |a| a.created_at.strftime("%-m/%-d/%y") }
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :email
      f.input :bio
      f.input :github_profile_username
      f.input :github_og_image
      f.input :github_og_url
      f.input :twitter_handle
    end
    f.actions
  end
end
