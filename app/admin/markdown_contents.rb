ActiveAdmin.register MarkdownContent do
  menu priority: 11

  config.filters = false
  config.batch_actions = false

  permit_params :name, :slug, :markdown

  actions :all, except: [:destroy]

  index download_links: false do
    column(:name) do |content|
      link_to content.name, admin_markdown_content_path(content)
    end
    column :slug
    column(:created_at, sortable: :created_at) do |content|
      content.created_at.strftime("%-m/%-d/%y")
    end
    column(:updated_at, sortable: :updated_at) do |content|
      content.updated_at.strftime("%-m/%-d/%y")
    end
    actions
  end

  show do
    attributes_table_for(resource) do
      row :id
      row :name
      row :slug
      row :markdown do |content|
        admin_markdown(content.markdown, trusted: true)
      end
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)
    f.inputs do
      f.input :name
      f.input :slug
      f.input :markdown, as: :text, input_html: { rows: 20 }
    end
    f.actions
  end
end
