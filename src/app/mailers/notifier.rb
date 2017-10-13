class Notifier < ActionMailer::Base
  default from: 'samvera-connect@googlegroups.com ',
          content_type: "text/html"

  def password_reset_instructions(user)
    @user = user
    @sent_on = Time.now
    mail(to: @user.email, subject: 'Password Reset Instructions')
  end
end
