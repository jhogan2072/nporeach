require 'test_helper'

class SubscriptionTest < ActiveSupport::TestCase

  test 'should be created as a trial by default' do
    s = Subscription.new(plan: subscription_plans(:basic))
    assert_equal s.state, 'trial' 
  end

  test 'should be created as active with plans that are free' do
    subscription_plans(:basic).amount = 0
    s = Subscription.new(plan: subscription_plans(:basic))
    assert_equal s.state, 'active'
  end

  test 'should be created with a renewal date a month from now by default' do
    s = Subscription.create(plan: subscription_plans(:basic))
    assert_equal s.next_renewal_at.localtime.at_midnight, Time.now.advance(:months => 1).at_midnight
  end

  test 'should be created with a specified renewal date' do
    s = Subscription.create(plan: subscription_plans(:basic), next_renewal_at: 1.day.from_now)
    assert_equal s.next_renewal_at.localtime.at_midnight, Time.now.advance(:days => 1).at_midnight
  end

  test 'should be created with a renewal date based on the subscription plan renewal date' do
    s = Subscription.create(plan: subscription_plans(:basic), renewal_period: 3)
    assert_equal s.next_renewal_at.localtime.at_midnight, Time.now.advance(:months => 3).at_midnight
  end

  test 'should return the amount in pennies' do
    s = Subscription.new(:amount => 10)
    assert_equal s.amount_in_pennies, 1000
  end

  test 'should set values from the assigned plan' do
    s = Subscription.new(plan: subscription_plans(:basic))
    assert_equal s.amount, subscription_plans(:basic).amount
    assert_equal s.user_limit, subscription_plans(:basic).user_limit
  end

  test 'should need payment info when no card is saved and the plan is not free' do
    assert_equal Subscription.new(plan: subscription_plans(:basic)).needs_payment_info?, true
  end

  test 'should not need payment info when the card is saved and the plan is not free' do
    assert_equal Subscription.new(plan: subscription_plans(:basic), card_number: 'foo').needs_payment_info?, false
  end

  test 'should not need payment info when no card is saved but the plan is free' do
    subscription_plans(:basic).amount = 0
    assert_equal Subscription.new(plan: subscription_plans(:basic)).needs_payment_info?, false
  end

  test 'find_expiring_trials method works as expected(finds trials due in 7 days)' do
    Subscription.create(plan: subscription_plans(:basic), next_renewal_at: 7.days.from_now)
    s = Subscription.find_expiring_trials
    assert s.length > 0
  end

  test 'find_due method works as expected(finds active subscriptions due now)' do
    Subscription.create(plan: subscription_plans(:basic), state: 'active', next_renewal_at: Time.now)
    s = Subscription.find_due
    assert s.length > 0
  end
  
  test 'find_due method works in the past (finds active subscriptions due 2 days ago)' do
    Subscription.create(plan: subscription_plans(:basic), state: 'active', next_renewal_at: 2.days.ago)
    s = Subscription.find_due(2.days.ago)
    assert s.length > 0
  end

  test 'should set the amount based on the discounted plan amount' do
    @basic_amount = subscription_plans(:basic).amount
    subscription_plans(:basic).discount = SubscriptionDiscount.new(code: 'foo', amount: 2)
    s = Subscription.new(valid_subscription)
    assert_equal s.amount.to_f, (@basic_amount - 2).to_f
  end

  test 'should set the amount based on the account discount if present' do
    @basic_amount = subscription_plans(:basic).amount
    s = Subscription.new(discount: SubscriptionDiscount.new(code: 'bar', amount: 3))
    s.plan = subscription_plans(:basic)
    assert_equal s.amount.to_f, (@basic_amount - 3).to_f
  end

  test 'should set the amount based on the plan discount, if larger than the account discount' do
    @basic_amount = subscription_plans(:basic).amount
    s = Subscription.new(discount: SubscriptionDiscount.new(code: 'bar', amount: 1))
    subscription_plans(:basic).discount = SubscriptionDiscount.new(code: 'foo', amount: 2)
    s.plan = subscription_plans(:basic)
    assert_equal s.amount.to_f, (@basic_amount - 2).to_f
  end

  test 'when being created without a credit card, should not include card storage in the validation' do
    @sub = Subscription.new(plan: subscription_plans(:basic))
    assert @sub.valid?
  end

  test 'when being created with a card, should include card storage in the validation' do
    @sub = Subscription.new(plan: subscription_plans(:basic))
    @creditcard = ActiveMerchant::Billing::CreditCard.new(invalid_card)
    @address = SubscriptionAddress.new(valid_address)
    @sub.creditcard = @creditcard
    @sub.address = @address
    assert @sub.invalid?
    @sub.creditcard = ActiveMerchant::Billing::CreditCard.new(valid_card)
    assert @sub.valid?
  end  

end
