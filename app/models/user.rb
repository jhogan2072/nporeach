class User < ActiveRecord::Base
  belongs_to :account
  validates :email, :password, presence: true
  validates :email, :uniqueness => {:scope => :account_id}, format: { with: /\A[^@]+@[^@]+\z/ }
  validates :password, confirmation: true, length: {within: 6..128}

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable, :registerable and :timeoutable
  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :encryptable, :authentication_keys => [:email, :account_id]

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  attr_protected :account_id

  private

  def password_non_blank
    errors.add(:password, I18n.t('users.missingpassword')) if encrypted_password.blank?
  end
end
