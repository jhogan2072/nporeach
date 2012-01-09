ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def valid_address(attributes = {})
    {
      :first_name => 'John',
      :last_name => 'Doe',
      :address1 => '2010 Cherry Ct.',
      :city => 'Mobile',
      :state => 'AL',
      :zip => '36608',
      :country => 'US'
    }.merge(attributes)
  end
  
  def invalid_card(attributes = {})
    { :first_name => 'Joe', 
      :last_name => 'Doe',
      :month => 2, 
      :year => Time.now.year + 1, 
      :number => '2', 
      :type => 'bogus', 
      :verification_value => '123' 
    }.merge(attributes)
  end

  def valid_card(attributes = {})
    { :first_name => 'Joe', 
      :last_name => 'Doe',
      :month => 2, 
      :year => Time.now.year + 1, 
      :number => '1', 
      :type => 'bogus', 
      :verification_value => '123' 
    }.merge(attributes)
  end
  
  def valid_user(attributes = {})
    { :first_name => 'Bubba',
      :last_name => 'Smith',
      :password => 'foobar', 
      :password_confirmation => 'foobar',
      :email => "bubba@email.com"
    }.merge(attributes)
  end
  
  def valid_subscription(attributes = {})
    { :plan => subscription_plans(:basic),
      :subscriber => accounts(:localhost)
    }.merge(attributes)
  end
end
