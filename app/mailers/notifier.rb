class Notifier < ActionMailer::Base
  default from: "Minnestar Support <support@minnestar.org>",
          content_type: "text/html"

  def password_reset_instructions(participant)
    @participant = participant
    @sent_on = Time.now
    mail(to: @participant.email, subject: "Password Reset Instructions for Minnebar")
  end

  def participant_email_confirmation(participant)
    @participant = participant
    mail(to: participant.email, subject: "Confirm your email for Minnebar")
  end
end
