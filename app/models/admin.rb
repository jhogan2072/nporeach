class Admin < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable 
  devise :database_authenticatable, :timeoutable, :registerable, :encryptable,
         :recoverable, :rememberable, :trackable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
end
