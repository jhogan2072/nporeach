class DefaultRole < ActiveRecord::Base
  has_many :default_grants, :dependent => :destroy
  has_many :privileges, :through => :default_grants
  validates :name, uniqueness: true, presence: true

  def self.search(search)
    if search #&& column_name && self.column_names.include?(column_name)
      where('name LIKE ?', "%#{search}%")
    else
      scoped
    end
  end

end
