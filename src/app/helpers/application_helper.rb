# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def edit(obj, &blk)
    return unless logged_in?
    if obj == current_participant || obj.try(:participant_id) == current_participant.id
      concat(capture(&blk))
    end
  end

  def markdown(str)
    return '' unless str
    @markdown ||= Redcarpet::Markdown.new(
        Redcarpet::Render::HTML.new,
        autolink: true,
        space_after_headers: true)
    sanitize_html(close_tags(@markdown.render(str))).html_safe
  end

  def close_tags(html)
    Nokogiri::HTML::DocumentFragment.parse(html).to_html
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
    link_to 'Add Session', new_session_path, class: 'button', alt: "Add Session"
  end

  def toggle_attendance_button(session)
    if session.event.current?
      content_tag(:button, "Attending", class: "toggle-attendance", 'data-session-id': session.id)
    end
  end
end
