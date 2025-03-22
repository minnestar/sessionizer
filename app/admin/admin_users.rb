ActiveAdmin.register AdminUser do
  menu priority: 10, parent: "Admin"
  permit_params :email, :password, :password_confirmation

  config.filters = false

  index do
    id_column
    column :email
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    actions
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
