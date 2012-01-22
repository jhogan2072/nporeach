class ColumnPreference < ActiveRecord::Base
  belongs_to :user
  validates :user_id, :presence => true
  validates :model_name, :presence => true
  validates :column_order, :presence => true
  validates :column_name, :presence => true, :uniqueness => {:scope => [:user_id, :model_name]}
end
