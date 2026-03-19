ActiveAdmin.register EventCategory do
  menu parent: "Events", priority: 4

  config.batch_actions = false
  config.sort_order = 'position_asc'

  permit_params :event_id, :category_id, :position

  filter :event
  filter :category

  controller do
    def scoped_collection
      super.includes(:event, :category)
    end

    def update
      update! do |format|
        format.html { redirect_to admin_event_categories_path(q: { event_id_eq: resource.event_id }) }
      end
    end
  end

  index do
    session_counts = Categorization
      .joins(:session)
      .where(sessions: { event_id: collection.map(&:event_id).uniq, canceled_at: nil })
      .group("sessions.event_id", :category_id)
      .count

    column :event
    column :category do |ec|
      link_to ec.category.name, admin_category_path(ec.category)
    end
    column :position
    column "# of Sessions" do |ec|
      count = session_counts[[ec.event_id, ec.category_id]] || 0
      link_to count, admin_sessions_path(q: { event_id_eq: ec.event_id, categorizations_category_id_eq: ec.category_id })
    end
    actions
  end

  show do
    attributes_table_for(resource) do
      row :id
      row :event
      row :category
      row :position
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)
    f.inputs do
      f.input :event
      f.input :category
      f.input :position
    end
    f.actions
  end
end
