class DefaultRole < ActiveRecord::Base
  has_many :default_grants
  has_many :privileges, :through => :default_grants
  scope :for, lambda{|controller, action|
        where("privileges.controller = ? AND ? & default_grants.operation > 0", 
        controller, Privilege::OPERATION_MAPPINGS[action])
  }
end
