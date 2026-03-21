# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def edit(obj, &blk)
    return unless logged_in?
    if obj == current_participant || obj.try(:participant_id) == current_participant.id
      concat(capture(&blk))
    end
  end

  def admin_markdown(str, trusted: false)
    content_tag(:div, markdown(str, trusted: trusted), class: "markdown-content")
  end

  def markdown(str, trusted: false)
    return '' unless str

    @markdown ||= Redcarpet::Markdown.new(
      Redcarpet::Render::HTML.new,
      autolink: true,
      space_after_headers: true
    )

    if trusted
      sanitize(close_tags(@markdown.render(str))).html_safe
    else
      sanitize_html(close_tags(@markdown.render(str))).html_safe
    end
  end

  def close_tags(html)
    Nokogiri::HTML::DocumentFragment.parse(html.scrub).to_html
  end

  def generate_meta_description(event = Event.current_event)
    return "Minnebar is a participant-led unconference free and open to all." unless event

    desc = "#{event.name} is a participant-led unconference free and open to all."
    held = event.date && event.date < Date.current ? "It was held" : "It'll be held"

    if event.start_time && event.end_time
      s = event.start_time.in_time_zone
      e = event.end_time.in_time_zone
      if s.to_date == e.to_date
        date_str = "#{s.strftime('%A, %B')} #{s.day.ordinalize}, #{s.strftime('%Y')}"
        desc += " #{held} on #{date_str} from #{event.display_time}"
      else
        start_str = "#{s.strftime('%A, %B')} #{s.day.ordinalize}"
        end_str = "#{e.strftime('%A, %B')} #{e.day.ordinalize}, #{e.strftime('%Y')}"
        desc += " #{held} #{start_str} - #{end_str}"
      end
    elsif event.date
      desc += " #{held} on #{event.date.strftime('%A, %B')} #{event.date.day.ordinalize}, #{event.date.strftime('%Y')}"
    end

    desc += " at #{event.venue}" if event.venue.present?
    desc += "." unless desc.end_with?(".")
    desc
  end

  def meta_description
    content_for?(:meta_description) ? content_for(:meta_description) : generate_meta_description
  end

  def sanitize_html(html)
    sanitize html,
      tags: %w(a img b i em strong p br ul ol li),
      attributes: %w(href src height width alt)
  end

  def add_sessions_button
    if Settings.allow_new_sessions?
      options = { class: 'button', alt: "Add Session" }
      if Event.current_event && current_participant&.sessions&.for_current_event&.any?
        options[:data] = { confirm: Session::DUPLICATE_SESSION_WARNING }
      end
      link_to 'Add Session', new_session_path, options
    end
  end

  def toggle_attendance_button(event, session)
    if event.current?
      content_tag(:button, "Attending", class: "toggle-attendance", 'data-session-id': session.id)
    end
  end
end
