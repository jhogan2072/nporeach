class User < ActiveRecord::Base
  before_save :create_family_if_needed
  belongs_to :account
  belongs_to :family
  has_many :assignments, :dependent => :destroy
  has_many :roles, :through => :assignments
  has_many :column_preferences, :dependent => :destroy
  accepts_nested_attributes_for :column_preferences
  attr_accessible :column_preferences_attributes
  has_many :user_preferences, :dependent => :destroy
  accepts_nested_attributes_for :user_preferences, :allow_destroy => true
  attr_accessible :user_preferences_attributes
  #validates :email, presence: true
  #validates :family_id, presence: true
  validates :last_name, :first_name, presence: true
  validates :email, :uniqueness => {:scope => :account_id}, format: { with: /\A[^@]+@[^@]+\z/ }, :if => :email?
  validates :password, presence: true, :if => :password_required?
  validates_confirmation_of :password, :if => :password_required?
  validates_length_of       :password, :within => 6..128, :allow_blank => true


  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable, :registerable
  devise :database_authenticatable, :timeoutable, :recoverable, :rememberable, :trackable, :encryptable, :authentication_keys => [:email, :account_id]
  
  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  attr_protected :account_id

  DESIGNATIONS = {1 => I18n.t('users.designations.student'),
    2 => I18n.t('users.designations.parent'),
    4 => I18n.t('users.designations.donor'),
    8 => I18n.t('users.designations.employee')
  }

  ETHNIC_ORIGINS = {1 => I18n.t('users.ethnic_origins.africanamerican'),
    2 => I18n.t('users.ethnic_origins.asian'),
    4 => I18n.t('users.ethnic_origins.latino'),
    8 => I18n.t('users.ethnic_origins.nativeamerican'),
    16 => I18n.t('users.ethnic_origins.white'),
    32 => I18n.t('users.ethnic_origins.other')
  }

  def self.search(search)
    if search #&& column_name && self.column_names.include?(column_name)
      where('last_name LIKE ?', "%#{search}%")
    else
      scoped
    end
  end

  def formatted_dob
    I18n.l(self.dob, :format => :short) if self.dob
  end
  def formatted_dob=(date_str)
    unless date_str.nil? || date_str.empty?
      self.dob = Date.strptime(date_str, I18n.translate("date.formats.short"))
    end
  end

  def get_user_pref(pref_key)
    self.user_preferences.where("pref_key = ?", pref_key).order("seq_no")
  end

  def set_user_pref(pref_key, pref_values)
    pref_values.each_with_index do |value, index|
      current_value = self.user_preferences.where("user_id = ? and pref_key = ?", self.id, pref_key)
      if current_value.empty?
        self.user_preferences.build(:pref_key => pref_key, :pref_value => value, :seq_no => index)
        self.save
      else
        current_value.update(current_value.first.id, :pref_key => pref_key, :pref_value => value, :seq_no => index)
        #self.user_preferences.find(current_value.first.id).update_attributes(:pref_key => pref_key, :pref_value => value, :seq_no => index, :without_protection => true)
      end
    end
  end

  def get_column_prefs(collection_name)
    ColumnPreference.where("user_id = ? and collection_name = ?", self.id, collection_name).order('column_order')
  end

  def full_name
    fullname = read_attribute(:last_name)
    if self.first_name
      fullname += ", " + read_attribute(:first_name)
      if self.middle_name
        fullname += " " + read_attribute(:middle_name)
      end
    end
    return fullname
  end

  def can?(controller, action)
    is_global_privilege(controller, action) || roles.includes(:privileges).for(controller, action).any?
  end
  
  protected
    # Checks whether a password is needed or not. For validations only.
    # Passwords are always required if it's a new record, or if the password
    # or confirmation are being set somewhere.
    def password_required?
      #!persisted? || !password.nil? || !password_confirmation.nil?
      !password.nil? || !password_confirmation.nil?
    end

    def is_global_privilege(controller, action)
      Privilege::GLOBAL_PRIVILEGES.include?(controller + "#" + action)
    end

  private
    def create_family_if_needed
      return unless self.new_record? && self.family_id.nil?

      @family = Family.new(:name => self.last_name, :is_individual => true, :mailing_greeting => self.first_name + " " + self.last_name)
      @family.account_id = self.account_id
      @family.save
      self.family_id = @family.id
    end
end
