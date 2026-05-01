ActiveAdmin.register Event do
  menu priority: 1

  config.filters = false
  config.batch_actions = false

  permit_params :name, :date, :venue, :start_time, :end_time

  # eager load associations on the show page
  controller do
    before_action only: [:edit, :update] do
      if resource.date && resource.date < Date.current
        redirect_to admin_event_path(resource), alert: "Past events cannot be edited."
      end
    end

    def scoped_collection
      collection = super
      if action_name == "show"
        collection.includes(
          sessions: [
            :timeslot,
            :room,
            { presentations: :participant }
          ]
        )
      else
        collection
      end
    end
  end

  # don't allow delete or edit past events
  actions :all, except: [:destroy]

  # remove default edit button, replaced with conditional one below
  config.action_items.delete_if { |item| item.name == :edit }

  action_item :edit_event, only: :show do
    if resource.date.nil? || resource.date >= Date.current
      link_to "Edit Event", edit_admin_event_path(resource), class: 'action-item-button'
    end
  end

  member_action :generate_categories, method: :post do
    begin
      Category.create_defaults_for_event(resource)
      redirect_to request.referer || admin_event_path(resource), notice: 'Default categories generated!'
    rescue => e
      redirect_to request.referer || admin_event_path(resource), alert: "Failed to generate categories: #{e.message}"
    end
  end

  action_item :generate_categories, only: :show do
    if resource.event_categories.empty?
      button_to 'Generate categories',
        generate_categories_admin_event_path(resource),
        method: :post,
        class: 'action-item-button cursor-pointer',
        data: { confirm: "This will generate default categories for this event based on the currently active categories. Are you sure you want to do this?" }
    end
  end

  member_action :generate_timeslots, method: :post do
    resource.create_default_timeslots
    redirect_to request.referer || admin_event_path(resource), notice: 'Timeslots successfully generated!'
  rescue => e
    redirect_to request.referer || admin_event_path(resource), alert: "Failed to generate timeslots: #{e.message}"
  end

  member_action :generate_rooms, method: :post do
    resource.create_default_rooms
    redirect_to request.referer || admin_event_path(resource), notice: 'Rooms successfully generated!'
  rescue => e
    redirect_to request.referer || admin_event_path(resource), alert: "Failed to generate rooms: #{e.message}"
  end

  member_action :assign_rooms, method: :post do
    reassign = params[:reassign].present?

    if reassign && resource.starts_within?(24.hours)
      redirect_to(request.referer || admin_event_path(resource),
                  alert: "Reassign all rooms is disabled within 24 hours of the event start.") and return
    end

    result = resource.assign_rooms!(reassign: reassign)

    notice = reassign ? "Rooms reassigned." : "Rooms assigned."
    if result[:already_assigned_count] > 0 && !reassign
      notice += " #{result[:already_assigned_count]} sessions already had rooms; use Reassign All to redo them."
    end
    redirect_to request.referer || admin_event_path(resource), notice: notice
  rescue => e
    redirect_to request.referer || admin_event_path(resource),
                alert: "Room assignment failed: #{e.message}. Try running `rails app:assign_rooms` in the terminal to see the full output."
  end

  action_item :generate_timeslots, only: :show do
    if resource.timeslots_count.zero?
      button_to 'Generate timeslots',
        generate_timeslots_admin_event_path(resource),
        method: :post,
        class: 'action-item-button cursor-pointer',
        data: { confirm: "This will generate #{Settings.default_timeslots.size} timeslots based on the defaults in Event Settings. Are you sure you want to proceed?" }
    end
  end

  action_item :generate_rooms, only: :show do
    if resource.rooms_count.zero?
      active_count = Settings.default_rooms.count { |r| r["active"] != false }
      button_to 'Generate rooms',
        generate_rooms_admin_event_path(resource),
        method: :post,
        class: 'action-item-button cursor-pointer',
        data: { confirm: "This will generate #{active_count} rooms based on the defaults in Event Settings. Are you sure you want to proceed?" }
    end
  end

  action_item :assign_rooms, only: :show do
    if resource.current? && resource.rooms_count > 0 && resource.has_unassigned_sessions?
      button_to 'Assign rooms',
        assign_rooms_admin_event_path(resource),
        method: :post,
        class: 'action-item-button cursor-pointer',
        data: { confirm: "Assign rooms to scheduled sessions that don't yet have one? This will take a little while. Sit tight." }
    end
  end

  action_item :reassign_rooms, only: :show do
    if resource.current? && resource.rooms_count > 0 && !resource.starts_within?(24.hours)
      button_to 'Reassign all rooms',
        assign_rooms_admin_event_path(resource, reassign: 1),
        method: :post,
        class: 'action-item-button cursor-pointer',
        data: { confirm: "This will OVERWRITE existing room assignments based on current vote tallies (manually-scheduled sessions are left alone). Are you sure?" }
    end
  end

  action_item :availability_matrix, only: :show do
    if resource.rooms_count > 0 && resource.timeslots_count > 0
      link_to "Room availability matrix",
        admin_room_availability_path(event_id: resource.id),
        class: "action-item-button"
    end
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :date
      f.input :start_time
      f.input :end_time
      f.input :venue
    end
    f.actions
  end

  index do
    column :name do |event|
      link_to event.name, admin_event_path(event)
    end
    column :date
    column(:time, &:display_time)
    column :venue
    column("# of Sessions") do |event|
      link_to event.sessions_count, admin_sessions_path(q: { event_id_eq: event.id })
    end
    column("# of Rooms") do |event|
      link_to event.rooms_count, admin_event_rooms_path(event)
    end
    column("# of Timeslots") do |event|
      link_to event.timeslots_count, admin_event_timeslots_path(event)
    end
  end

  show do
    event_categories = event.event_categories.ordered.includes(:category)
    session_counts_by_category = Categorization
      .joins(:session)
      .where(sessions: { event_id: event.id, canceled_at: nil })
      .group(:category_id)
      .count

    attributes_table do
      row :name
      row :date
      row(:time, &:display_time)
      row :venue
      row "Meta Description" do |event|
        helpers.generate_meta_description(event)
      end
      row("Event URL") do |event|
        link_to event_url(event), event_url(event), target: "_blank"
      end
      row("Schedule URL") do |event|
        link_to event_schedule_url(event), event_schedule_url(event), target: "_blank"
      end
      row "# of Categories" do |event|
        link_to event_categories.size, admin_event_categories_path(q: { event_id_eq: event.id })
      end
      row "# of Sessions" do |event|
        active_count = event.sessions.count
        canceled_count = event.sessions.with_canceled.canceled.count
        text_node link_to(active_count, admin_sessions_path(q: { event_id_eq: event.id }))
        text_node " (+#{canceled_count} canceled)" if canceled_count > 0
      end
      row "# of Rooms" do |event|
        text_node link_to(event.rooms_count, admin_event_rooms_path(event))
        if event.rooms_count > 0 && event.timeslots_count > 0
          text_node " ("
          text_node link_to("availability matrix", admin_room_availability_path(event_id: event.id))
          text_node ")"
        end
      end
      row "# of Timeslots" do |event|
        link_to event.timeslots_count, admin_event_timeslots_path(event)
      end
      row :created_at
      row :updated_at
    end

    if event.current?
      settings = Settings.first
      panel ("Event Settings (#{link_to 'edit', edit_admin_setting_path(1)})").html_safe do
        attributes_table_for settings do
          row "Allow New Sessions" do
            settings.allow_new_sessions
          end
          row "Show Schedule" do
            settings.show_schedule
          end
          row "Default Timeslots" do
            "#{settings.default_timeslots.size} slots"
          end
          row "Default Rooms" do
            rooms = Settings.default_rooms
            active_count = rooms.count { |r| r["active"] != false }
            "#{rooms.size} rooms (#{active_count} active)"
          end
        end
      end
    end

    panel ("#{link_to 'Event Timeslots', admin_event_timeslots_path(event)} (#{event.timeslots_count})").html_safe do
      table_for event.timeslots do
        column :title do |timeslot|
          link_to timeslot.title, admin_event_timeslot_path(event, timeslot)
        end
        column(:display, &:to_s)
        column :schedulable
        column("Sessions", sortable: :sessions_count) do |timeslot|
          link_to(
            timeslot.sessions.size,
            admin_sessions_path(order: "attendances_count_desc", q: { event_id_eq: timeslot.event_id, timeslot_id_eq: timeslot.id })
          )
        end
      end
    end

    panel ("#{link_to 'Event Categories', admin_event_categories_path(q: { event_id_eq: event.id })} (#{event_categories.size})").html_safe do
      table_for event_categories do
        column :position
        column :name do |ec|
          link_to ec.category.name, edit_admin_event_category_path(ec)
        end
        column :long_name do |ec|
          ec.category.long_name
        end
        column :tagline do |ec|
          ec.category.tagline
        end
        column "# of Sessions" do |ec|
          count = session_counts_by_category[ec.category_id] || 0
          link_to count, admin_sessions_path(q: { event_id_eq: event.id, categorizations_category_id_eq: ec.category_id })
        end
      end
    end

    panel ("#{link_to 'Event Sessions', admin_sessions_path(q: { event_id_eq: event.id })} (#{event.sessions_count})").html_safe do
      # Define allowed sort columns and their database equivalents
      sortable_columns = {
        'title' => 'sessions.title',
        'attendances_count' => 'sessions.attendances_count',
        'timeslot_id' => 'sessions.timeslot_id',
        'room' => 'rooms.name',
        'created_at' => 'sessions.created_at'
      }

      # Get sort column and direction from params, with validation
      raw_sort = params[:order]&.gsub(/_desc|_asc/, '')  # Remove direction suffix

      # If sort param exists, use it; otherwise use default sort (timeslot, room capacity,then votes)
      order_clause = if params[:order].present?
        sort_column = sortable_columns[raw_sort] || 'sessions.timeslot_id'
        sort_direction = params[:order]&.end_with?('desc') ? 'desc' : 'asc'
        Arel.sql("#{sort_column} #{sort_direction}")
      else
        Arel.sql('sessions.timeslot_id, rooms.capacity DESC, sessions.canceled_at DESC, sessions.attendances_count DESC')
      end

      sessions = event.sessions
                     .with_canceled
                     .includes(:presenters, :attendances, :timeslot, :room)
                     .joins('LEFT JOIN rooms ON rooms.id = sessions.room_id')
                     .order(order_clause)

      table_for sessions, sortable: true do
        column :title, sortable: :title do |session|
          (link_to(session.title.truncate(80), admin_session_path(session)) +
          (session.canceled? ? " (CANCELED)" : "")).html_safe
        end
        column :presenters, sortable: false do |session|
          presenters = session.presenters
          if presenters.size > 3
            presenters = presenters.first(2)
            presenter_links = presenters.map do |presenter|
              link_to presenter.name, admin_participant_path(presenter)
            end
            [presenter_links, " and #{session.presenters.size - 2} others"].join(", ").html_safe
          else
            presenters.map { |presenter| link_to presenter.name, admin_participant_path(presenter) }.join(", ").html_safe
          end
        end
        column("Votes", sortable: :attendances_count, &:attendances_count)
        column :timeslot, sortable: :timeslot_id do |session|
          link_to session.timeslot&.to_s, admin_event_timeslot_path(session.event, session.timeslot) if session.timeslot
        end
        column :room, sortable: :room_id do |session|
          link_to session.room&.name, admin_event_room_path(session.event, session.room) if session.room
        end
        column("Canceled", sortable: :canceled_at, &:canceled?)
        column("Created", sortable: :created_at) do |session|
          session.created_at.strftime("%-m/%-d/%y")
        end
      end
    end
  end
  
end
