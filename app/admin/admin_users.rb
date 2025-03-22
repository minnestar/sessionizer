ActiveAdmin.register AdminUser do
  menu priority: 10, parent: "Admin"
  permit_params :email, :password, :password_confirmation

  config.filters = false

  index do
    column :id
    column :email do |admin_user|
      link_to admin_user.email, admin_admin_user_path(admin_user)
    end
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    column :updated_at
  end

  form do |f|
    f.inputs do
      f.input :email
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end

end
