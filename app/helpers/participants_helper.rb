module ParticipantsHelper
  include ActionView::Helpers::UrlHelper

  def email_confirmation_link(participant)
    link_to "Confirm your email", send_confirmation_email_participant_path(participant), method: :post
  end

  def email_confirmation_alert(participant)
    "Your email has not been confirmed. Please #{email_confirmation_link(participant)}.".html_safe
  end
end 