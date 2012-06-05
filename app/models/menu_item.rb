class MenuItem < ActiveRecord::Base
  has_many :child_menu_items, :dependent => :destroy
  accepts_nested_attributes_for :child_menu_items, :allow_destroy => true, :reject_if => lambda {|a| a!="is_collection" && a[:value].blank?}
  attr_accessible :child_menu_items_attributes
  attr_accessible :name, :help_text, :category, :controller, :action
  validates :name, presence:true
  validates :controller, uniqueness: {scope: :action}

  def self.current_menu(current_user)
    menu_items = []
    MenuItem.all.each do |menu_item|
      menu_items << menu_item if current_user.can?(menu_item.controller, menu_item.action)
    end
    if menu_items.length > 0
      cur_menu = menu_items.group_by { |mi| mi.category  }
      menu = Hash.new
      cur_menu.each do |k, v|
        menu[k] = v.map {|i| Array[i.controller, i.action, i.help_text, i.name, i.id]}
      end
    end
    return menu if defined?(menu)
  end
  
  def allowed_child_menu_items(current_user)
    cmis = Array.new
    self.child_menu_items.each do |cmi|
      cmis << cmi if current_user.can?(cmi.controller, cmi.action) # && cmi.is_collection
    end
    if cmis.length > 0
      child_menu = Array.new
      cmis.each_with_index do |cmi, index|
        child_menu[index] = Array[cmi.controller, cmi.action, cmi.help_text, cmi.name, cmi.id]
      end
    end
    return child_menu if defined?(child_menu)
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
