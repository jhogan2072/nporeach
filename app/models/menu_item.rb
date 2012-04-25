class MenuItem < ActiveRecord::Base
  validates :name, presence:true, uniqueness: true

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

  def self.search(search)
    if search #&& column_name && self.column_names.include?(column_name)
      where('name LIKE ?', "%#{search}%")
    else
      scoped
    end
  end
end
