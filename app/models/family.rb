class Family < ActiveRecord::Base
  belongs_to :account
  has_many :users, :dependent => :destroy
  has_one :primary_contact, :class_name => "User", :conditions => { :is_primary_contact => true }
  accepts_nested_attributes_for :primary_contact
  validates :name, presence: true
  attr_accessible :name, :mailing_greeting, :is_individual, :primary_contact_attributes

  def self.search(search)
    if search #&& column_name && self.column_names.include?(column_name)
      where('name LIKE ?', "%#{search}%")
    else
      scoped
    end
  end

end
