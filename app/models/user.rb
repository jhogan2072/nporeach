class User < ActiveRecord::Base
  belongs_to :account
  has_many :roles, :through => :assignments
  validates :email, presence: true
  validates :email, :uniqueness => {:scope => :account_id}, format: { with: /\A[^@]+@[^@]+\z/ }
  # validates :password, confirmation: true, length: {within: 6..128}
  validates_presence_of     :password, :if => :password_required?
  validates_confirmation_of :password, :if => :password_required?
  validates_length_of       :password, :within => 6..128, :allow_blank => true

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable, :registerable and :timeoutable
  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :encryptable, :authentication_keys => [:email, :account_id]

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  attr_protected :account_id

  protected
    # Checks whether a password is needed or not. For validations only.
    # Passwords are always required if it's a new record, or if the password
    # or confirmation are being set somewhere.
    def password_required?
      debugger
      !persisted? || !password.nil? || !password_confirmation.nil?
    end

    def can?(controller, action)
      roles.includes(:privileges).for(controller, action).any?
    end

end
