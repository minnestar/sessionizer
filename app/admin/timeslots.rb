ActiveAdmin.register Timeslot do
  menu parent: "Events", label: "Timeslots"
  config.filters = false

  belongs_to :event

  permit_params :event_id, :starts_at, :ends_at, :schedulable, :title
  config.sort_order = 'starts_at_asc'

  actions :all, except: [:destroy]

  index do
    column :id
    column :event
    column("Date") do |timeslot|
      timeslot.starts_at.in_time_zone.strftime("%B %e, %Y")
    end
    column :title
    column(:display, &:to_s)
    # column :starts_at
    # column :ends_at
    column :schedulable
    actions
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
