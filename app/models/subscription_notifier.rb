class SubscriptionNotifier < ActionMailer::Base
  include ActionView::Helpers::NumberHelper

  default :from => Saas::Config.from_email
  
  def setup_environment(obj)
    if obj.is_a?(SubscriptionPayment)
      @subscription = obj.subscription
      @amount = obj.amount
    elsif obj.is_a?(Subscription)
      @subscription = obj
    end
    @subscriber = @subscription.subscriber
    tmp_relation = @subscriber.account_settings.setting_value('settings.accountnotificationemail')
    if tmp_relation.any?
      @notification_email = tmp_relation.first.value
    end
  end
  
  def welcome(account)
    @subscriber = account
    mail(:to => account.owner.email, :subject => "Welcome to #{Saas::Config.app_name}!")
  end
  
  def trial_expiring(subscription)
    setup_environment(subscription)
    mail(:to => @subscriber.email, :subject => 'Trial period expiring')
  end
  
  def charge_receipt(subscription_payment)
    setup_environment(subscription_payment)
    @notification_email ||= @subscriber.email
    mail(:to => @notification_email, :subject => "Your #{Saas::Config.app_name} invoice")
  end
  
  def setup_receipt(subscription_payment)
    setup_environment(subscription_payment)
    @notification_email ||= @subscriber.email
    mail(:to => @notification_email, :subject => "Your #{Saas::Config.app_name} invoice")
  end
  
  def misc_receipt(subscription_payment)
    setup_environment(subscription_payment)
    @notification_email ||= @subscriber.email
    mail(:to => @notification_email, :subject => "Your #{Saas::Config.app_name} invoice")
  end
  
  def charge_failure(subscription)
    setup_environment(subscription)
    @notification_email ||= @subscriber.email
    mail(:to => @notification_email, :subject => "Your #{Saas::Config.app_name} renewal failed",
      :bcc => Saas::Config.from_email)
  end
  
  def plan_changed(subscription)
    setup_environment(subscription)
    @notification_email ||= @subscriber.email
    mail(:to => @notification_email, :subject => "Your #{Saas::Config.app_name} plan has been changed")
  end
end
