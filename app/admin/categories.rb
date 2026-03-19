ActiveAdmin.register Category do
  menu parent: "Events", priority: 3

  config.batch_actions = false
  config.filters = false
  config.sort_order = "default_position_asc"

  scope :all
  scope :active, default: true
  scope :inactive
  scope :legacy

  permit_params :name, :long_name, :tagline, :description, :active, :default_position

  index do
    column :name
    column :long_name
    column :active
    column(:legacy, &:legacy?)
    column :default_position
    actions
  end

  show do
    attributes_table do
      row :id
      row :default_position
      row :name
      row :long_name
      row(:display_long_name)
      row :tagline
      row :description
      row :active
      row(:legacy, &:legacy?)
    end

    event_categories = category.event_categories.includes(:event).order('events.date DESC')
    session_counts = category.sessions.group(:event_id).count

    panel "Events Using This Category (#{event_categories.size})" do
      table_for event_categories do
        column :event do |ec|
          link_to ec.event.name, admin_event_path(ec.event)
        end
        column :position do |ec|
          link_to ec.position, edit_admin_event_category_path(ec)
        end
        column "# of Sessions" do |ec|
          count = session_counts[ec.event_id] || 0
          link_to count, admin_sessions_path(q: { event_id_eq: ec.event_id, categorizations_category_id_eq: ec.category_id })
        end
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :long_name, hint: "Full descriptive name. Leave blank if same as name."
      f.input :tagline
      f.input :description
      f.input :active, hint: "Inactive categories won't be included when generating defaults for new events."
      f.input :default_position, hint: "Order when generating defaults for new events. Lower numbers appear first."
    end
    f.actions
  end
end
