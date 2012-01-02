class Role < ActiveRecord::Base
  belongs_to :account
  has_many :grants, :dependent => :destroy
  has_many :privileges, :through => :grants
  has_many :assignments, :dependent => :destroy
  has_many :users, :through => :assignments
  scope :for, lambda{|controller, action|
        where("privileges.controller = ? AND ? & grants.operation > 0", 
        controller, Privilege::OPERATION_MAPPINGS[action])
  }
  validates :name, :uniqueness => {:scope => :account_id}, presence: true

  attr_protected :account_id

  def self.search(search)
    if search #&& column_name && self.column_names.include?(column_name)
      where('name LIKE ?', "%#{search}%")
    else
      scoped
    end
  end


end
