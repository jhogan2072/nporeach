class DefaultPrivilege < ActiveRecord::Base
  has_many :default_grants
  has_many :default_roles, :through => :default_grants
  validates :name, uniqueness: true, presence: true

  def self.search(search)
    if search #&& column_name && self.column_names.include?(column_name)
      where('name LIKE ?', "%#{search}%")
    else
      scoped
    end
  end

end
