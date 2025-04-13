# frozen_string_literal: true

ActiveAdmin.register Settings do
  menu priority: 10, parent: "Events", label: "Event Settings"
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

  permit_params :allow_new_sessions, :show_schedule, :timeslot_config

  show title: "Current Event Settings" do
    attributes_table title: "Settings"do
      row("Current Event") do
        Event.current_event.name
      end
      row :allow_new_sessions
      row :show_schedule
      row("Timeslot Config") do |settings|
        pre settings.timeslot_config.map { |slot|
          ordered_slot = { "start" => slot["start"], "end" => slot["end"] }
          ordered_slot["special"] = slot["special"] if slot["special"].present?
          JSON.generate(ordered_slot).gsub(/,/, ', ')
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
      f.input :timeslot_config,
        as: :text,
        label: "Timeslot Config (JSON)",
        input_html: {
          value: f.object.timeslot_config.map { |slot|
            ordered_slot = { "start" => slot["start"], "end" => slot["end"] }
            ordered_slot["special"] = slot["special"] if slot["special"].present?
            JSON.generate(ordered_slot).gsub(/,/, ', ')
          }.join(",\n"),
          rows: 20
        },
        hint: "Format: {\"start\":\"8:00\", \"end\":\"8:30\", \"special\":\"Registration / Breakfast\"}, {\"start\":\"8:30\", \"end\":\"8:50\", \"special\":\"Kickoff\"}"
    end
    f.actions
  end
end
