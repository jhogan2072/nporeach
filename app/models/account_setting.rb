class AccountSetting < ActiveRecord::Base
  belongs_to :account
  belongs_to :setting
  validates :setting_id, presence: true, :uniqueness => {:scope => :account_id}
  attr_protected :account_id
  
  def self.search(search)
    if search #&& column_name && self.column_names.include?(column_name)
      where('value LIKE ?', "%#{search}%")
    else
      scoped
    end
  end
end
