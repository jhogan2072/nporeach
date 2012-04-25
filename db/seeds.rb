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

default_role1 = DefaultRole.create(:name => 'admin.default_roles.names.systemadministrator')
privilege1 = Privilege.create(:name => 'admin.privileges.names.managepeople', :description => 'admin.privileges.descriptions.managepeople', :controller => 'families', :category => 'ADMINISTRATION', :actions => 63)
privilege2 = Privilege.create(:name => 'admin.privileges.names.manageroles', :description => 'admin.privileges.descriptions.manageroles', :controller => 'roles', :category => 'ADMINISTRATION', :actions => 63)
privilege3 = Privilege.create(:name => 'admin.privileges.names.managesettings', :description => 'admin.privileges.descriptions.managesettings', :controller => 'account_settings', :category => 'ADMINISTRATION', :actions => 3)
privilege4 = Privilege.create(:name => 'admin.privileges.names.manageaccountinfo', :description => 'admin.privileges.descriptions.manageaccountinfo', :controller => 'accounts', :category => 'ADMINISTRATION', :actions => 2047)
default_role2 = DefaultRole.create(:name => 'admin.default_roles.names.familymember')
privilege5 = Privilege.create(:name => 'admin.privileges.names.personalinfo', :description => 'admin.privileges.descriptions.personalinfo', :controller => 'users', :category => 'PERSONAL', :actions => 64)
privilege6 = Privilege.create(:name => 'admin.privileges.names.changepassword', :description => 'admin.privileges.descriptions.changepassword', :controller => 'users', :category => 'PERSONAL', :actions => 128)
privilege7 = Privilege.create(:name => 'admin.privileges.names.addmembers', :description => 'admin.privileges.descriptions.addmembers', :controller => 'families', :category => 'PERSONAL', :actions => 64)

default_role1.default_grants.create(:default_role_id => default_role1.id, :privilege_id => privilege1.id)
default_role1.default_grants.create(:default_role_id => default_role1.id, :privilege_id => privilege2.id)
default_role1.default_grants.create(:default_role_id => default_role1.id, :privilege_id => privilege3.id)
default_role1.default_grants.create(:default_role_id => default_role1.id, :privilege_id => privilege4.id)
default_role2.default_grants.create(:default_role_id => default_role2.id, :privilege_id => privilege5.id)
default_role2.default_grants.create(:default_role_id => default_role2.id, :privilege_id => privilege6.id)
default_role2.default_grants.create(:default_role_id => default_role2.id, :privilege_id => privilege7.id)

Setting.create(:name => 'settings.timeperiodname', :description => 'settings.timeperioddesc', :default_value => 'Semester')
Setting.create(:name => 'settings.accountnotificationemail', :description => 'settings.accountnotificationemaildesc')
Setting.create(:name => 'settings.billingitemname', :description => 'settings.billingitemdesc', :default_value => 'Class')
Setting.create(:name => 'settings.registrantname', :description => 'settings.registrantnamedesc', :default_value => 'Student')

MenuItem.create(:name => 'admin.menu_items.names.account', :help_text => 'admin.menu_items.help_text.manageaccountinformation', :category => 'ADMINISTRATION', :controller => 'accounts', :action => 'show')
MenuItem.create(:name => 'admin.menu_items.names.people', :help_text => 'admin.menu_items.help_text.managefamilies', :category => 'ADMINISTRATION', :controller => 'families', :action => 'index')
MenuItem.create(:name => 'admin.menu_items.names.roles', :help_text => 'admin.menu_items.help_text.manageroles', :category => 'ADMINISTRATION', :controller => 'roles', :action => 'index')
MenuItem.create(:name => 'admin.menu_items.names.settings', :help_text => 'admin.menu_items.help_text.manageaccountsettings', :category => 'ADMINISTRATION', :controller => 'accounts', :action => 'settings')
MenuItem.create(:name => 'admin.menu_items.names.personalinfo', :help_text => 'admin.privileges.descriptions.personalinfo', :category => 'PERSONAL', :controller => 'users', :action => 'profile')
MenuItem.create(:name => 'admin.privileges.names.changepassword', :help_text => 'admin.privileges.descriptions.changepassword', :category => 'PERSONAL', :controller => 'users', :action => 'password')
MenuItem.create(:name => 'admin.privileges.names.addmembers', :help_text => 'admin.privileges.descriptions.addmembers', :category => 'PERSONAL', :controller => 'families', :action => 'my_family')
