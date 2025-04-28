ActiveAdmin.register Event do
  menu priority: 1
  permit_params :name, :date

  # eager load associations on the show page
  controller do
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

  config.filters = false

  # don't allow delete
  actions :all, except: [:destroy]

  action_item :generate_timeslots, only: :show do
    if resource.timeslots_count.zero?
      link_to 'Generate timeslots',
        generate_timeslots_admin_event_path(resource),
        method: :post,
        data: { confirm: "This will generate #{Settings.default_timeslots.size} timeslots based on the defaults in Event Settings. Are you sure you want to proceed?" }
    end
  end

  member_action :generate_timeslots, method: :post do
    begin
      if resource.create_default_timeslots
        redirect_to request.referer || admin_event_path(resource), notice: 'Timeslots successfully generated!'
      else
        redirect_to request.referer || admin_event_path(resource), alert: 'Failed to generate timeslots.'
      end
    rescue => e
      redirect_to request.referer || admin_event_path(resource), alert: "Failed to generate timeslots #{e.message}"
    end
  end

  index do
    column :id
    column :name do |event|
      link_to event.name, admin_event_path(event)
    end
    column :date
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
    attributes_table do
      row :name
      row :date
      row "# of Sessions" do |event|
        link_to event.sessions_count, admin_sessions_path(q: { event_id_eq: event.id })
      end
      row "# of Rooms" do |event|
        link_to event.rooms_count, admin_event_rooms_path(event)
      end
      row "# of Timeslots" do |event|
        link_to event.timeslots_count, admin_event_timeslots_path(event)
      end
      row "Timeslots" do |event|
        if event.timeslots_count.zero?
          link_to "Generate timeslots",
            generate_timeslots_admin_event_path(event),
            method: :post,
            data: { confirm: "This will generate #{Settings.default_timeslots.size} timeslots based on the defaults in Event Settings. Are you sure you want to proceed?" }
        else
          event.timeslots.map do |timeslot|
            link_to timeslot.to_s, admin_event_timeslot_path(event, timeslot)
          end.join('<br>').html_safe
        end
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
        end
      end
    end

    panel "Event Sessions (#{event.sessions_count})" do
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

      # If sort param exists, use it; otherwise use default sort (timeslot, then votes)
      order_clause = if params[:order].present?
        sort_column = sortable_columns[raw_sort] || 'sessions.timeslot_id'
        sort_direction = params[:order]&.end_with?('desc') ? 'desc' : 'asc'
        Arel.sql("#{sort_column} #{sort_direction}")
      else
        Arel.sql('sessions.timeslot_id, sessions.attendances_count DESC')
      end

      sessions = event.sessions
                     .includes(:presenters, :attendances, :timeslot, :room)
                     .joins('LEFT JOIN rooms ON rooms.id = sessions.room_id')
                     .order(order_clause)

      table_for sessions, sortable: true do
        column :title, sortable: :title do |session|
          link_to truncate(session.title, length: 80), admin_session_path(session)
        end
        column :presenters, sortable: false do |session|
          session.presenters.map { |presenter| link_to presenter.name, admin_participant_path(presenter) }.join(", ").html_safe
        end
        column("Votes", sortable: :attendances_count, &:attendances_count)
        column :timeslot, sortable: :timeslot_id do |session|
          link_to session.timeslot&.to_s, admin_event_timeslot_path(session.event, session.timeslot) if session.timeslot
        end
        column :room, sortable: :room_id do |session|
          link_to session.room&.name, admin_event_room_path(session.event, session.room) if session.room
        end
        column("Created", sortable: :created_at) do |session|
          session.created_at.strftime("%-m/%-d/%y")
        end
      end
    end
  end
  
end
