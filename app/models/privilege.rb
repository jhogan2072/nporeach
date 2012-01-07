class Privilege < ActiveRecord::Base
  belongs_to :account
  has_many :grants
  has_many :roles, :through => :grants
  validates_uniqueness_of :controller, :scope => [:account_id, :operations]
  validates :name, :uniqueness => {:scope => :account_id}, presence: true

  attr_protected :account_id

  CATEGORIES = {
    "ADMINISTRATION" => ["registrations.png",I18n.t('privilegemodel.administration')], 
    "SCHEDULES" => ["schedule.png",I18n.t('privilegemodel.schedules')], 
    "REGISTRATIONS" => ["registrations.png", I18n.t('privilegemodel.registrations')],
    "EMPLOYEES" => ["employees.png", I18n.t('privilegemodel.employees')],
    "PAYMENTS" => ["payments.png", I18n.t('privilegemodel.payments')],
    "STUDENTS" => ["students.png", I18n.t('privilegemodel.students')],
  }
  
#This maps controllers to categories.  It is used by the privileges_controller to automatically populate category for the user based on the controller they've picked
#The second field in the array corresponds to the translated name for the controller that the user sees in the drop-down
  CONTROLLERS = {
    "accounts" => ["ADMINISTRATION", I18n.t('privilegemodel.accounts')],
    "users" => ["ADMINISTRATION", I18n.t('privilegemodel.users')],
    "privileges" => ["ADMINISTRATION", I18n.t('privilegemodel.privileges')],
    "roles" => ["ADMINISTRATION", I18n.t('privilegemodel.roles')],
  }

  OPERATIONS = {
    "read" => 1,
    "create" => 2,
    "update" => 4,
    "delete" => 8,
  }

  GLOBAL_PRIVILEGES = ["sessions#new", "sessions#create", "sessions#destroy", "accounts#dashboard"]

  OPERATION_MAPPINGS = {
    "dashboard" => Privilege::OPERATIONS["read"],
    "show" => Privilege::OPERATIONS["read"],
    "index" => Privilege::OPERATIONS["read"],
    "new" => Privilege::OPERATIONS["create"],
    "create" => Privilege::OPERATIONS["create"],
    "update" => Privilege::OPERATIONS["update"],
    "destroy" => Privilege::OPERATIONS["delete"],
    "plan" => Privilege::OPERATIONS["update"],
    "billing" => Privilege::OPERATIONS["update"],
    "cancel" => Privilege::OPERATIONS["update"]
  }

  def self.search(search)
    if search #&& column_name && self.column_names.include?(column_name)
      where('name LIKE ?', "%#{search}%")
    else
      scoped
    end
  end

end
