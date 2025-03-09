ActiveAdmin.register Participant do
  permit_params :name, :email, :bio, :github_profile_username, :github_og_image, :github_og_url, :twitter_handle, :email_confirmed_at

  filter :name
  filter :email

  index do
    column :name do |participant|
      link_to participant.name, admin_participant_path(participant)
    end
    column :email
    column :bio
    column(:confirmed, &:email_confirmed?)
    column(:created_at) { |p| p.created_at.strftime("%Y-%m-%d") }
    actions
  end

  show do
    attributes_table do
      row :name
      row :email
      row :bio
      row :github_profile_username
      row :github_og_image
      row :github_og_url
      row :twitter_handle
      row :email_confirmed_at
      row :created_at
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
