class DefaultGrant < ActiveRecord::Base
  belongs_to :default_role
  belongs_to :default_privilege
  validates_uniqueness_of :default_privilege_id, :scope => :default_role_id
end
