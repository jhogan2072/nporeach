class Role < ActiveRecord::Base
  has_many :grants
  has_many :assignments
  has_many :users, :through => :assignments
  has_many :privileges, :through => :grants
  scope :for, lambda{|controller, action|
        where("privileges.controller = ? AND privileges.action = ?", 
        controller, action)
  }
end
