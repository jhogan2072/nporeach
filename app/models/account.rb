class Account < ActiveRecord::Base
  has_many :privileges, :dependent => :destroy
  has_many :users, :dependent => :destroy
  has_many :roles, :dependent => :destroy
  has_one :admin, :class_name => "User", :conditions => { :admin => true }
  after_create :create_roles_and_privileges
  accepts_nested_attributes_for :admin

  #
  # Set up the account to own subscriptions. An alternative would be to
  # call 'has_subscription' on the user model, if you only want one user per
  # subscription.  See has_subscription in vendor/plugins/saas/lib/saas.rb
  # for info on how to use the options for implementing limit checking.
  #
  has_subscription :user_limit => Proc.new {|a| a.users.count }

  #
  # The model with "has_subscription" needs to provide an email attribute.
  # But ours is stored in the user model, so we delegate
  #
  delegate :email, :to => :admin
  
  validates_format_of :domain, :with => /\A[a-zA-Z][a-zA-Z0-9]*\Z/
  validates_exclusion_of :domain, :in => %W( support blog www billing help api ), :message => I18n.t('accountmodel.domainnotavailable')
  validates_presence_of :admin, :on => :create, :message => I18n.t('accountmodel.adminmissing')
  validates_associated :admin, :on => :create
  validate :valid_domain?
  
  attr_accessible :name, :domain, :admin_attributes
  
  acts_as_paranoid
  
  def domain
    @domain ||= self.full_domain.blank? ? '' : self.full_domain.split('.').first
  end
  
  def domain=(domain)
    @domain = domain
    self.full_domain = "#{domain}.#{Saas::Config.base_domain}"
  end
  
  def to_s
    name.blank? ? full_domain : "#{name} (#{full_domain})"
  end

  protected
    def create_roles_and_privileges
      DefaultPrivilege.all.each do |default_privilege|
        privilege = self.privileges.new
        privilege.update_attributes(default_privilege.attributes)
        grant = privilege.grants.new

      end
      DefaultRole.all.each do |default_role|
        role = self.roles.new
        role.update_attributes(default_role.attributes)
        default_role.default_grants.all.each do |default_grant|
          grant = role.grants.new
          grant.privilege_id = Privilege.where("name = ? and account_id = ?", default_grant.default_privilege.name, self.id).first!.id
          grant.role_id = role.id
          grant.save!
       end
      end
      # Handle the unlikely case that we can't find a matching privilege for a default_privilege, i.e. the previous insertion failed
      rescue ActiveRecord::RecordNotFound
        logger.error("Unable to create a default grant for the #{self.name} account - could be a general database problem.")
        # TODO: email the sysadmin notifying them of this condition, as it is probably a bad one
    end
  
    def valid_domain?
      conditions = new_record? ? ['full_domain = ?', self.full_domain] : ['full_domain = ? and id <> ?', self.full_domain, self.id]
      self.errors.add(:domain, 'is not available') if self.full_domain.blank? || self.class.count(:conditions => conditions) > 0
    end
    
end
