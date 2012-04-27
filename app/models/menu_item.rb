class MenuItem < ActiveRecord::Base
  has_many :child_menu_items, :dependent => :destroy
  accepts_nested_attributes_for :child_menu_items, :allow_destroy => true, :reject_if => :all_blank
  attr_accessible :child_menu_items_attributes
  attr_accessible :name, :help_text, :category, :controller, :action
  validates :name, presence:true
  validates :controller, uniqueness: {scope: :action}

  def self.current_menu(current_user)
      menu_items = []
      if current_user.owner?
        menu_items = self.all
      else
        self.each do |menu_item|
          menu_items << menu_item if current_user.can?(menu_item.controller, menu_item.action)
        end
      end
      if menu_items.length > 0
        cur_menu = menu_items.group_by { |mi| mi.category  }
        menu = Hash.new
        cur_menu.each do |k, v|
          menu[k] = v.map {|i| Array[i.controller, i.action, i.help_text, i.name]}
        end
      end
      return menu if defined?(menu)
  end

  def with_blank_children(n = 1)
    n.times do
      child_menu_items.build
    end
    self
  end

  def self.search(search)
    if search #&& column_name && self.column_names.include?(column_name)
      where('name LIKE ?', "%#{search}%")
    else
      scoped
    end
  end
end
