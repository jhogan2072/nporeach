class DefaultPrivilege < ActiveRecord::Base
  has_many :default_grants
  has_many :default_roles, :through => :default_grants
end
