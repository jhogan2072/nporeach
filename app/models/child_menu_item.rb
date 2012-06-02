class ChildMenuItem < ActiveRecord::Base
  belongs_to :menu_item
  validates :name, presence:true

end
