# frozen_string_literal: true

ActiveAdmin.register Settings do
  menu priority: 10, parent: "Admin", label: "Event Settings"
  config.filters = false
  actions :index, :edit, :update, :show

  controller do
    def find_resource
      Settings.first
    end
  end

  permit_params :allow_new_sessions, :show_schedule

  index do
    column :id
    column :allow_new_sessions
    column :show_schedule
    actions
  end

  show do
    attributes_table do
      row :allow_new_sessions
      row :show_schedule
    end
  end

  form do |f|
    f.inputs do
      f.input :allow_new_sessions
      f.input :show_schedule
    end
    f.actions
  end
end
