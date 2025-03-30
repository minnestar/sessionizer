# frozen_string_literal: true
ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
    settings = Settings.first

    columns do
      column do
        panel "Current Event" do
          attributes_table_for Event.includes(:sessions, :rooms, :timeslots).current_event do
            row :name
            row :date
            row "Allow New Sessions" do
              settings.allow_new_sessions
            end
            row "Show Schedule" do
              settings.show_schedule
            end
            row "# of Sessions" do |event|
              event.sessions_count
            end
            row "# of Rooms" do |event|
              event.rooms_count
            end
            row "# of Timeslots" do |event|
              event.timeslots_count
            end
          end
        end
      end
    end

    panel "Current Event Sessions" do
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

      sessions = Event.includes(:sessions)
                     .current_event
                     .sessions
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
