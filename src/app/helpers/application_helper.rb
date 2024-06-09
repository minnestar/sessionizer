# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def edit(obj, &blk)
    return unless logged_in?
    if obj == current_participant || obj.try(:participant_id) == current_participant.id
      concat(capture(&blk))
    end
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

  def meta_description
    content_for?(:meta_description) ? content_for(:meta_description) : 'Minnebar'
  end

  def sanitize_html(html)
    sanitize html,
      tags: %w(a img b i em strong p br ul ol li),
      attributes: %w(href src height width alt)
  end

  def add_sessions_button
    if Settings.allow_new_sessions?
      link_to 'Add Session', new_session_path, class: 'button', alt: "Add Session"
    end
  end

  def toggle_attendance_button(event, session)
    if event.current?
      content_tag(:button, "Attending", class: "toggle-attendance", 'data-session-id': session.id)
    end
  end
end
