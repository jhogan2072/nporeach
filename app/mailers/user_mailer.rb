class UserMailer < ActionMailer::Base
  default from: Saas::Config.from_email

  def new_message(addresses, message)
    @message = message
    mail(:to => addresses, :subject => "#{message.subject}")
  end
end
