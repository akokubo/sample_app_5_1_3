class UserMailer < ApplicationMailer

  def account_activation(user)
    @user = user
    # heroku config:set MAIL_FROM="activation mail address"
    from = ENV['MAIL_FROM'] ||= 'noreply@example.com'
    mail from: from, to: user.email, subject: "Account activation"
  end

  def password_reset
    @greeting = "Hi"

    mail to: "to@example.org"
  end
end
