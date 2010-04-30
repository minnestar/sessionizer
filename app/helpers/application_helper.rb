# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def edit(obj, &blk)
    if logged_in? && obj == current_participant || (obj.respond_to?(:participant) && obj.participant == current_participant)
      concat(capture(&blk))
    end
  end
end
