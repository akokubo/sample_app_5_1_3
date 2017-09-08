class UserMailer < ApplicationMailer

  def account_activation(user)
    @user = user
    # heroku config:set MAIL_FROM="activation and reset mail address"
    from = ENV['MAIL_FROM'] ||= 'noreply@example.com'
    mail from: from, to: user.email#, subject: t('.subject')
  end

  def password_reset(user)
    @user = user
    # heroku config:set MAIL_FROM="activation and reset mail address"
    from = ENV['MAIL_FROM'] ||= 'noreply@example.com'
    mail from: from, to: user.email#, subject: t('.subject')
  end
end
