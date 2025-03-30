ActiveAdmin.register Event do
  menu priority: 1
  permit_params :name, :date

  # Only eager load associations on the show page
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
      event.rooms_count
    end
    column("# of Timeslots") do |event|
      event.timeslots_count
    end
  end

  show do
    attributes_table do
      row :name
      row :date
      row :timeslots
      row "# of Rooms" do |event|
        event.rooms_count
      end
      row("# of Sessions") do |event|
        link_to event.sessions_count, admin_sessions_path(q: { event_id_eq: event.id })
      end
      row :created_at
      row :updated_at
    end

    panel "Sessions (#{event.sessions_count})" do
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
        column("Votes", :attendances_count, sortable: :attendances_count) do |session|
          session.attendances_count
        end
        column :timeslot, sortable: :timeslot_id do |session|
          session.timeslot&.to_s
        end
        column :room, sortable: :room do |session|
          session.room&.name
        end
        column("Created", sortable: :created_at) do |session|
          session.created_at.strftime("%-m/%-d/%y")
        end
      end
    end
  end
  
end
