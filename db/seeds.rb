# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
#
# Create the default privileges and roles
plans = [
        { 'name' => 'Free', 'amount' => 0, 'renewal_period' => 1, 'trial_period' => 1, 'user_limit' => 5, 'description' => 'subscriptionplandesc1' },
        { 'name' => 'Monthly', 'amount' => 510, 'renewal_period' => 1, 'trial_period' => 0, 'user_limit' => nil, 'description' => 'subscriptionplandesc2' },
        { 'name' => 'Annual', 'amount' => 1500, 'renewal_period' => 12, 'trial_period' => 0, 'user_limit' => nil, 'description' => 'subscriptionplandesc3' }
      ].collect do |plan|
        SubscriptionPlan.create(plan)
      end

Admin.create(:email => 'johnehogan@yahoo.com', :password => 'welcome', :password_confirmation => 'welcome')

default_role1 = DefaultRole.create(:name => 'System Administrator')
privilege1 = Privilege.create(:name => 'Manage Users', :description => 'Administer account users', :controller => 'users', :category => 'ADMINISTRATION', :actions => 63)
privilege2 = Privilege.create(:name => 'Manage Roles', :description => 'Administer roles that are specific to this account', :controller => 'roles', :category => 'ADMINISTRATION', :actions => 63)
privilege3 = Privilege.create(:name => 'Manage Settings', :description => 'Personalize the system with settings for your account', :controller => 'account_settings', :category => 'ADMINISTRATION', :actions => 3)
privilege4 = Privilege.create(:name => 'Manage Account Information', :description => 'Change the name of the organization, update billing information, update the account owner, cancel the account.', :controller => 'accounts', :category => 'ADMINISTRATION', :actions => 2047)

default_role1.default_grants.create(:default_role_id => default_role1.id, :privilege_id => privilege1.id)
default_role1.default_grants.create(:default_role_id => default_role1.id, :privilege_id => privilege2.id)
default_role1.default_grants.create(:default_role_id => default_role1.id, :privilege_id => privilege3.id)
default_role1.default_grants.create(:default_role_id => default_role1.id, :privilege_id => privilege4.id)

Setting.create(:name => 'Time Period Name', :description => 'The name for a session of classes, e.g. semester, quarter, trimester, etc.', :default_value => 'Semester')
Setting.create(:name => 'Account Notification Email', :description => 'The email address or addresses where account notifications should be sent.')
Setting.create(:name => 'Billing Item Name', :description => 'The name for an item billed to a customer, e.g. a class, course, lesson, etc.', :default_value => 'Class')
Setting.create(:name => 'Registrant Name', :description => 'The name for a session participant, e.g. student, participant', :default_value => 'Student')

MenuItem.create(:name => 'Users', :help_text => 'Manage Users', :category => 'ADMINISTRATION', :controller => 'users', :action => 'index')
MenuItem.create(:name => 'Roles', :help_text => 'Manage User Roles', :category => 'ADMINISTRATION', :controller => 'roles', :action => 'index')
MenuItem.create(:name => 'Settings', :help_text => 'Manage Account Settings', :category => 'ADMINISTRATION', :controller => 'account_settings', :action => 'edit_all')
MenuItem.create(:name => 'Account', :help_text => 'Manage Account Information', :category => 'ADMINISTRATION', :controller => 'accounts', :action => 'show')
MenuItem.create(:name => 'Billing', :help_text => 'Manage Billing Information', :category => 'ADMINISTRATION', :controller => 'accounts', :action => 'billing')