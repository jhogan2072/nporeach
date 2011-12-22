class Grant < ActiveRecord::Base
  belongs_to :role
  belongs_to :privilege
  validates_uniqueness_of :privilege_id, :scope => :role_id
end
