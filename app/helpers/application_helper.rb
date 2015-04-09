# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def edit(obj, &blk)
    if logged_in? && obj == current_participant || (obj.respond_to?(:participant) && obj.participant == current_participant)
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

  def sanitize_html(html)
    sanitize html,
      tags: %w(a img b i em strong p br ul ol li),
      attributes: %w(href src height width alt)
  end

  def add_sessions_button
    link_to image_tag('button-add-session.png', :title => 'Add session', :size => "215x43", :border=>"0"), new_session_path, :id => 'add-sessions-button'
  end
end
