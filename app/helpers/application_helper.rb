module ApplicationHelper
  # Render a submit button and cancel link
  def submit_or_cancel(cancel_url = session[:return_to] ? session[:return_to] : url_for(:action => 'index'), label = 'Save Changes')
    raw(content_tag(:div, submit_tag(label) + ' or ' +
      link_to('Cancel', cancel_url), :id => 'submit_or_cancel', :class => 'submit'))
  end

  def discount_label(discount)
    (discount.percent? ? number_to_percentage(discount.amount * 100, :precision => 0) : number_to_currency(discount.amount)) + ' off'
  end

  def hide_ul_if(condition, attributes = {}, &block)
    if condition || (controller_name == 'accounts' && action_name == 'dashboard')
      attributes["style"] = "display: none"
    end
    content_tag("ul", attributes, &block)
  end

  def is_current(active_action, submenus)
    if active_action.nil?
      return (controller_name == submenus.controller)
    else
      return (controller_name == submenus.controller && action_name == submenus.action)
    end
  end

  def submenu_url(submenus, active_action)
    link_to(content_tag("span", submenus.name),
      url_for(:controller => submenus.controller,
      :action => submenus.action),
      :title => submenus.name,
      :alt => submenus.help_text,
      :class => (is_current(active_action, submenus))? "current" : "")
  end

  def header_link(link_text, link_to_controller, link_to_action, column )
    css_class = (column == sort_column) ? "current #{sort_direction}" : nil
    direction = (column == sort_column && sort_direction == "asc") ? "desc" : "asc"
    link_to(link_text, url_for(params.merge(:controller => link_to_controller, :action => link_to_action, :sort => column, :direction => direction, :page => nil)), :class => (css_class.nil? ?  "" : css_class + " ") + "column_header", remote: true) 
  end

  def page_title(pagetitle)
    unless current_account.nil?
      unless pagetitle.nil?
        current_account.name + " - " + pagetitle
      else
        current_account.name
      end
    else
      ""
    end
  end

  def has_privilege(privilege, current_privileges)
    retval = false
    unless privilege.nil? || current_privileges.nil?
      retval = true if (privilege & current_privileges > 0)
    end
    return retval
  end

  def privilege_div(controller_name, current_privileges)
    if controller_name
      retval = ""
      Privilege::CONTROLLER_ACTIONS[controller_name].each_pair do |key, value|
        retval += content_tag("div", check_box_tag('allowed_actions[]', value, has_privilege(value, current_privileges), :class => "checkbox_group") + content_tag("span", key, :class => "checkbox_label"))
      end
      return retval.html_safe
    else
      content_tag("div", content_tag("label", "Please choose a controller"), :class => "checkbox_group")
    end
  end

  def link_for_privilege(priv_controller)
      url_for :action => Privilege::ROOT_MENU_ACTIONS[priv_controller], :controller => priv_controller
  end

end
