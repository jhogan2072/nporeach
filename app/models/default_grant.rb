class DefaultGrant < ActiveRecord::Base
  belongs_to :default_role
  belongs_to :default_privilege
  validates_uniqueness_of :privilege_id, :scope => :role_id
end
