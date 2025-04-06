ActiveAdmin.register Timeslot do
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

    panel "Sessions" do
      table_for timeslot.sessions.order('sessions.attendances_count DESC') do
        column :title do |session|
          link_to session.title, admin_session_path(session)
        end
        column :presenters
        column :room
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
