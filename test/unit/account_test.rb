require 'test_helper'

class AccountTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test 'account should be invalid with a missing admin' do
    account = Account.new(domain: accounts(:localhost).name, description: accounts(:localhost).description, plan: subscription_plans(:basic))
    assert account.invalid?
    assert_equal I18n.t('accountmodel.adminmissing'), account.errors[:admin].join('; ')
  end

  test 'account should be invalid with an invalid admin' do
    account = Account.new(domain: accounts(:localhost).name, description: accounts(:localhost).description, plan: subscription_plans(:basic), admin_attributes: User.new.attributes )
    assert account.invalid?
    assert_equal I18n.t('accountmodel.adminnotvalid'), account.errors[:admin].join('; ')
  end

  test "account should set the full domain when created" do
    account = Account.new(domain: 'foo', plan: subscription_plans(:free), admin_attributes: valid_user )
    assert_equal account.full_domain, "foo.#{Saas::Config.base_domain}"
  end

  test "account should require payment info when being created with a paid plan when the app configuration requires it" do
    Saas::Config.require_payment_info_for_trials = true
    account = Account.new(domain: 'foo', admin_attributes: valid_user, plan: subscription_plans(:basic))
    assert account.needs_payment_info?
  end

  test "account should not require payment info when being created with a paid plan when the app configuration does not require it" do
    Saas::Config.require_payment_info_for_trials = false
    account = Account.new(domain: 'foo', admin_attributes: valid_user, plan: subscription_plans(:basic))
    assert !account.needs_payment_info?
  end

  test "account should not require payment info when being created with free plan" do
    account = Account.new(domain: 'foo', admin_attributes: valid_user, plan: subscription_plans(:free))
    assert !account.needs_payment_info?
  end

  test "account should be invalid without valid payment and address info with a paid plan" do
    account = Account.new(domain: 'foo', admin_attributes: valid_user, plan: subscription_plans(:advanced))
    assert account.invalid?
    assert account.errors[:base].join('; ').include? I18n.t('saas.invalidpaymentinformation')
    assert account.errors[:base].join('; ').include? I18n.t('saas.invalidaddress')
  end

  test "account should create the user when created" do
    account = Account.create(name: 'bar', domain: 'foo', admin_attributes: valid_user, plan: subscription_plans(:free))
    user = User.where(:first_name => 'Bubba').first
    assert_equal user, account.admin
    assert user.valid?
    assert user.admin?
  end

  test "account should create the subscription when created" do
    account = Account.create(name: 'bar', domain: 'foo', admin_attributes: valid_user, plan: subscription_plans(:free))
    assert_equal Subscription.find(:first, :order => 'id desc').subscriber, account
  end

  test "account should create the subscription with an associated affiliate" do
    affiliate = subscription_affiliates(:bob)
    account = Account.new(name: 'bar', domain: 'foo', admin_attributes: valid_user, plan: subscription_plans(:free))
    account.affiliate = affiliate
    account.save
    assert_equal Subscription.find(:first, :order => 'id desc').affiliate, affiliate
  end

  test "default roles and privileges are created" do
    account = Account.create(name: 'bar', domain: 'foo', admin_attributes: valid_user, plan: subscription_plans(:free))
    assert_equals account.roles.first.name DefaultRole.find(:first).name
  end

end
