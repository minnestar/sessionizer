ActiveAdmin.register Participant do
  menu priority: 3

  permit_params :name, :email, :bio, :github_profile_username, :github_og_image, :github_og_url, :twitter_handle, :email_confirmed_at

  includes :attendances, { presentations: { session: :event } }

  filter :name
  filter :email

  index do
    column :id
    column :name do |participant|
      link_to participant.name, admin_participant_path(participant)
    end
    column :email
    column :bio
    column(:confirmed, &:email_confirmed?)
    column(:presentations) { |p| p.presentations.size }
    column(:attendances) { |p| p.attendances.size }
    column(:created_at) { |p| p.created_at.strftime("%Y-%m-%d") }
    actions
  end

  show do
    attributes_table do
      row :name
      row :email
      row :bio
      row(:presentation_count) { |p| p.presentations.size }
      row(:attendance_count) { |p| p.attendances.size }
      row("Confirmed") do |p|
        status_tag p.email_confirmed? ? "Yes" : "No", class: p.email_confirmed? ? :ok : :error
      end
      row :email_confirmed_at
      row :created_at
    end
    panel "Presentations" do
      table_for participant.presentations do
        column(:title) { |p| link_to p.session.title, admin_session_path(p.session) }
        column(:event) { |p| link_to p.session.event.name, admin_event_path(p.session.event) }
        column(:date) { |p| p.session.event.date }
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
