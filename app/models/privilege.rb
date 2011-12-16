class Privilege < ActiveRecord::Base
  has_many :grants
  has_many :roles, :through => :grants
end
