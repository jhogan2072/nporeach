class Privilege < ActiveRecord::Base
  belongs_to :account
  has_many :grants
  has_many :roles, :through => :grants
  validates_uniqueness_of :controller, :scope => :account_id

  CATEGORIES = ["Schedule", "Registrations", "Payments", "Students", "Employees"]

  OPERATIONS = {
    "read" => 1,
    "create" => 2,
    "update" => 4,
    "delete" => 8,
  }


  OPERATION_MAPPINGS = {
    "show" => Privilege::OPERATIONS["read"],
    "index" => Privilege::OPERATIONS["read"],
    "new" => Privilege::OPERATIONS["create"],
    "create" => Privilege::OPERATIONS["create"],
    "update" => Privilege::OPERATIONS["update"],
    "destroy" => Privilege::OPERATIONS["delete"]
  }
  
end
