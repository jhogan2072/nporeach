module MenuItemsHelper

  def display_submenus_ul(category, menu_items, &block)
    attributes = {}
    attributes["id"] = 'submenu'
    current_category_match_found = find_match(current_menu[session[:current_category]], 0) unless session[:current_category].nil?
    if current_category_match_found
      if category == session[:current_category]
        content_tag("ul", attributes, &block)
      end
    else
      match_found = find_match(menu_items, 0)
      if match_found == true
        content_tag("ul", attributes, &block)
      end
    end
  end

  def find_match(menu_items, level)
    retval = false
    menu_items.each do |menu_item|
      if (menu_item[0] == controller_name && menu_item[1] == action_name)
        retval = true
      else
        if level == 0 && retval == false
          mi = MenuItem.find(menu_item[4])
          cm = mi.allowed_child_menu_items(current_user)
          unless cm.nil?
            retval = find_match(cm, 1)
          end
        end
      end
    end
    return retval
  end

  def submenu_link(submenu, category)
    link_to(content_tag("span", I18n.t(submenu[3])),
      url_for(:controller => submenu[0],
      :action => submenu[1]),
      :title => I18n.t(submenu[3]),
      :alt => I18n.t(submenu[2]),
      :class => (is_current(submenu, category))? "current" : "")
  end

  def is_current(submenu, category)
    result = false
    result = (submenu[0] == controller_name && submenu[1] == action_name)
    if result == false
      menu_item = MenuItem.find(submenu[4])
      cmis = menu_item.allowed_child_menu_items(current_user)
      unless menu_item.nil? || cmis.nil?
        result = cmis.any? { |menu_item| (menu_item[0] == controller_name && menu_item[1] == action_name) }
        if result
          session[:current_category] = menu_item.category
        end
      end
    else
      session[:current_category] = category
    end
    return result
  end

end
