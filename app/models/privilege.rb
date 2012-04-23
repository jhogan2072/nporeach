class Privilege < ActiveRecord::Base
  has_many :default_grants
  has_many :default_roles, :through => :default_grants
  validates :name, uniqueness: true, presence: true
  has_many :grants
  has_many :roles, :through => :grants
  validates_uniqueness_of :controller, :scope => :actions

  CATEGORIES = {
    "ADMINISTRATION" => ["registrations.png",I18n.t('privilegemodel.administration')], 
    "PERSONAL" => ["students.png", I18n.t('privilegemodel.personal')],
  }
  
  CONTROLLER_ACTIONS = {
    "account_settings" => {"settings" => 1, "update_settings" => 2},
    "accounts" => {"show" => 1, "edit" => 2, "update" => 4, "destroy" => 8, "change_owner" => 16, "plans" => 32, "plan" => 64, "billing" => 128, "paypal" => 256, "plan_paypal" => 512, "cancel" => 1024},
    "roles" => {"index" => 1, "new" => 2, "create" => 4, "edit" => 8, "update" => 16, "destroy" => 32},
    "families" => {"index" => 1, "new" => 2, "create" => 4, "edit" => 8, "update" => 16, "destroy" => 32},
    "users" => {"index" => 1, "new" => 2, "create" => 4, "edit" => 8, "update" => 16, "destroy" => 32}
  }
  
  ROOT_MENU_ACTIONS = {
    "account_settings" => "settings",
    "accounts" => "show",
    "roles" => "index",
    "families" => "index"
  }
  
  GLOBAL_PRIVILEGES = ["sessions#new", "sessions#create", "sessions#destroy", "accounts#show"]

  def self.privileges_by_category
    priv_array = []
    if self.all.length > 0
      self.all.each do |priv|
        priv_array << priv
      end
    end
    return priv_array.group_by {|priv| priv.category}
  end

  def self.search(search)
    if search #&& column_name && self.column_names.include?(column_name)
      where('name LIKE ?', "%#{search}%")
    else
      scoped
    end
  end

end
