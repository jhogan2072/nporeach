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
privilege1 = Privilege.create(:name => 'Manage People', :description => 'Create and edit families, students, donors, employees, and system users', :controller => 'familes', :category => 'ADMINISTRATION', :actions => 63)
privilege2 = Privilege.create(:name => 'Manage Roles', :description => 'Administer roles that are specific to this account', :controller => 'roles', :category => 'ADMINISTRATION', :actions => 63)
privilege3 = Privilege.create(:name => 'Manage Settings', :description => 'Personalize the system with settings for your account', :controller => 'account_settings', :category => 'ADMINISTRATION', :actions => 3)
privilege4 = Privilege.create(:name => 'Manage Account Information', :description => 'Change the name of the organization, update billing information, update the account owner, cancel the account.', :controller => 'accounts', :category => 'ADMINISTRATION', :actions => 2047)

default_role1.default_grants.create(:default_role_id => default_role1.id, :privilege_id => privilege1.id)
default_role1.default_grants.create(:default_role_id => default_role1.id, :privilege_id => privilege2.id)
default_role1.default_grants.create(:default_role_id => default_role1.id, :privilege_id => privilege3.id)
default_role1.default_grants.create(:default_role_id => default_role1.id, :privilege_id => privilege4.id)

Setting.create(:name => 'settings.timeperiodname', :description => 'settings.timeperioddesc', :default_value => 'Semester')
Setting.create(:name => 'settings.accountnotificationemail', :description => 'settings.accountnotificationemaildesc')
Setting.create(:name => 'settings.billingitemname', :description => 'settings.billingitemdesc', :default_value => 'Class')
Setting.create(:name => 'settings.registrantname', :description => 'settings.registrantnamedesc', :default_value => 'Student')

MenuItem.create(:name => 'admin.menu_items.names.account', :help_text => 'admin.menu_items.help_text.manageaccountinformation', :category => 'ADMINISTRATION', :controller => 'accounts', :action => 'show')
MenuItem.create(:name => 'admin.menu_items.names.people', :help_text => 'admin.menu_items.help_text.managefamilies', :category => 'ADMINISTRATION', :controller => 'families', :action => 'index')
MenuItem.create(:name => 'admin.menu_items.names.roles', :help_text => 'admin.menu_items.help_text.manageroles', :category => 'ADMINISTRATION', :controller => 'roles', :action => 'index')
MenuItem.create(:name => 'admin.menu_items.names.settings', :help_text => 'admin.menu_items.help_text.manageaccountsettings', :category => 'ADMINISTRATION', :controller => 'accounts', :action => 'settings')
