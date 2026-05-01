ActiveAdmin.register_page "Room Availability" do
  menu false

  content title: proc {
    event_id = params[:event_id]
    event = event_id.present? ? Event.find_by(id: event_id) : Event.current_event
    event ? "#{event.name}: Room Availability " : "Room Availability"
  } do
    event_id = params[:event_id]
    event = event_id.present? ? Event.find_by(id: event_id) : Event.current_event

    if event.nil?
      para "No event found. Pass ?event_id=... or create an event first."
      next
    end

    rooms = event.rooms.reorder(schedulable: :desc, capacity: :desc, id: :asc).to_a
    timeslots = event.timeslots.where(schedulable: true).reorder(:starts_at).to_a

    if rooms.empty? || timeslots.empty?
      para "This event has no schedulable timeslots or rooms yet."
      next
    end

    bookings = event.sessions
      .where(room_id: rooms.map(&:id), timeslot_id: timeslots.map(&:id), canceled_at: nil)
      .index_by { |s| [s.room_id, s.timeslot_id] }

    defaults = Settings.default_rooms
    notes_by_name = defaults.index_by { |r| r["name"] }
    unique_caps = defaults.group_by { |r| r["capacity"] }
                          .select { |_cap, rs| rs.size == 1 }
                          .transform_values(&:first)

    notes_for = ->(room) do
      match = notes_by_name[room.name] || unique_caps[room.capacity]
      match&.dig("notes")
    end

    div class: "overflow-x-auto" do
      table class: "min-w-full border-collapse text-sm" do
        thead do
          tr do
            th class: "sticky left-0 bg-white dark:bg-gray-900 text-left p-2 border-b" do
              "Room"
            end
            timeslots.each do |slot|
              th class: "p-2 border-b text-left align-bottom w-32" do
                slot.to_s
              end
            end
          end
        end
        tbody do
          rooms.each do |room|
            tr class: "border-b" do
              td class: "sticky left-0 bg-white dark:bg-gray-900 p-2 align-top" do
                div do
                  link_to(room.name, admin_event_room_path(event, room))
                end
                div(class: "text-xs text-gray-600") { "Capacity: #{room.capacity}" }
                if (room_notes = notes_for.call(room))
                  div(class: "text-xs text-gray-500 italic") { room_notes }
                end
                unless room.schedulable
                  div(class: "text-xs text-amber-700") { "(not schedulable)" }
                end
              end
              timeslots.each do |slot|
                td class: "p-2 align-top" do
                  if bookings[[room.id, slot.id]]
                    status_tag "No"
                  else
                    status_tag "Yes"
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end

