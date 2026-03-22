ActiveAdmin.register Settings do
  menu parent: "Events", priority: 2, label: "Event Settings"

  config.filters = false

  actions :index, :edit, :update, :show

  # assume there is only one settings object
  controller do
    def find_resource
      Settings.first
    end

    # make the index page redirect to the show page for the first settings record
    def index
      redirect_to admin_setting_path(Settings.first)
    end
  end

  permit_params :allow_new_sessions, :show_schedule, :default_timeslots, :default_rooms

  show title: "Current Event Settings" do
    attributes_table_for resource do
      row("Current Event") do
        link_to Event.current_event.name, admin_event_path(Event.current_event)
      end
      row :allow_new_sessions
      row :show_schedule
      row("Default Timeslots") do |settings|
        pre Settings.default_timeslots.map { |slot|
          start_padding = " " * (5 - slot["start"].length)
          parts = [%("start": "#{slot["start"]}",#{start_padding} "end": "#{slot["end"]}")]
          parts << %("special": "#{slot["special"]}") if slot["special"].present?
          "{#{parts.join(', ')}}"
        }.join(",\n")
      end
      row("Default Rooms") do |_settings|
        rooms = Settings.default_rooms
        max_name = rooms.map { |r| r["name"].length }.max
        pre rooms.map { |room|
          padding = " " * (max_name - room["name"].length)
          capacity = "%3d" % room["capacity"]
          parts = [%("name": "#{room["name"]}",#{padding} "capacity": #{capacity})]
          parts << %("active": false) if room.key?("active") && room["active"] == false
          parts << %("notes": "#{room["notes"]}") if room["notes"].present?
          "{#{parts.join(', ')}}"
        }.join(",\n")
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :current_event,
        as: :select,
        collection: [[Event.current_event.name, Event.current_event.id]],
        selected: Event.current_event.id,
        input_html: { disabled: true },
        label: "Current Event"
      f.input :allow_new_sessions
      f.input :show_schedule
      f.input :default_timeslots,
        as: :text,
        label: "Default Timeslots (JSON)",
        input_html: {
          value: f.object.default_timeslots_raw_value || Settings.default_timeslots.map { |slot|
            start_padding = " " * (5 - slot["start"].length)
            parts = [%("start": "#{slot["start"]}",#{start_padding} "end": "#{slot["end"]}")]
            parts << %("special": "#{slot["special"]}") if slot["special"].present?
            "{#{parts.join(', ')}}"
          }.join(",\n"),
          rows: 15,
          style: "font-family: monospace;"
        },
        hint: "Format: {\"start\":\"8:00\", \"end\":\"8:30\", \"special\":\"Registration / Breakfast\"}, {\"start\":\"8:30\", \"end\":\"8:50\", \"special\":\"Kickoff\"}, etc..."
      f.input :default_rooms,
        as: :text,
        label: "Default Rooms (JSON)",
        input_html: {
          value: f.object.default_rooms_raw_value || begin
            rooms = Settings.default_rooms
            max_name = rooms.map { |r| r["name"].length }.max
            rooms.map { |room|
              padding = " " * (max_name - room["name"].length)
              capacity = "%3d" % room["capacity"]
              parts = [%("name": "#{room["name"]}",#{padding} "capacity": #{capacity})]
              parts << %("active": false) if room.key?("active") && room["active"] == false
              parts << %("notes": "#{room["notes"]}") if room["notes"].present?
              "{#{parts.join(', ')}}"
            }.join(",\n")
          end,
          rows: 40,
          style: "font-family: monospace;"
        },
        hint: "Format: {\"name\":\"Theater\", \"capacity\":250}, {\"name\":\"Alaska\", \"capacity\":96, \"active\":false, \"notes\":\"Used for daycare in 2025\"}, etc.<br>- Use \"active\": false if a room isn't being used this year <br>- Use \"notes\": \"...\" to add context about a room".html_safe
    end
    f.actions
  end
end
