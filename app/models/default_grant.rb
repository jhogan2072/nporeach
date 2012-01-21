class DefaultGrant < ActiveRecord::Base
  belongs_to :default_role
  belongs_to :privilege
  validates_uniqueness_of :privilege_id, :scope => :default_role_id
end
