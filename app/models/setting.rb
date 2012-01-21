class Setting < ActiveRecord::Base
  has_many :account_settings, :dependent => :destroy
  validates :name, uniqueness: true, presence: true

  def self.search(search)
    if search #&& column_name && self.column_names.include?(column_name)
      where('name LIKE ?', "%#{search}%")
    else
      scoped
    end
  end
end
