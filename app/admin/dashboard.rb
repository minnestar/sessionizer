# frozen_string_literal: true
ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  current_event = Event.includes(:sessions, :rooms, :timeslots).current_event
  settings = Settings.first

  content title: proc { I18n.t("active_admin.dashboard") } do
    columns do
      column do
        panel "Current Event" do
          attributes_table_for current_event do
            row :name
            row :date
            row "Show Schedule" do
              settings.show_schedule
            end
            row "Allow New Sessions" do
              settings.allow_new_sessions
            end
            row "# of Sessions" do |event|
              event.sessions.size
            end
            row "# of Rooms" do |event|
              event.rooms.size
            end
            row "# of Timeslots" do |event|
              event.timeslots.size
            end
          end
        end
      end
    end

    panel "Current Event Sessions" do
      table_for current_event.sessions.includes(:presenters, :attendances, :timeslot, :room).order(:timeslot_id) do
        column :title do |session|
          link_to session.title, admin_session_path(session)
        end
        column :presenters do |session|
          session.presenters.map { |presenter| link_to presenter.name, admin_participant_path(presenter) }.join(", ").html_safe
        end
        column("Votes") do |session|
          session.attendances.size
        end
        column :timeslot do |session|
          session.timeslot&.to_s
        end
        column :room do |session|
          session.room&.name
        end
      end
    end
  end
end
