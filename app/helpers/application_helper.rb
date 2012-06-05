module ApplicationHelper
  # Render a submit button and cancel link
  def submit_or_cancel(cancel_url = session[:return_to] ? session[:return_to] : url_for(:action => 'index'), label = 'Save Changes')
    raw(content_tag(:div, submit_tag(label) + ' or ' +
      link_to('Cancel', cancel_url), :id => 'submit_or_cancel', :class => 'submit'))
  end

  def discount_label(discount)
    (discount.percent? ? number_to_percentage(discount.amount * 100, :precision => 0) : number_to_currency(discount.amount)) + ' off'
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

  def has_item(item, assigned_items)
    retval = false
    unless item.nil? || assigned_items.nil?
      retval = true if (item & assigned_items > 0)
    end
    return retval
  end

  def privilege_div(controller_name, current_privileges)
    if controller_name
      retval = ""
      Privilege::CONTROLLER_ACTIONS[controller_name].each_pair do |key, value|
        retval += content_tag("div", check_box_tag('allowed_actions[]', value, has_item(value, current_privileges), :class => "checkbox_group") + content_tag("span", key, :class => "checkbox_label"))
      end
      return retval.html_safe
    else
      content_tag("div", content_tag("label", "Please choose a controller"), :class => "checkbox_group")
    end
  end

  def designations_div(user_designations)
    retval = ""
    User::DESIGNATIONS.each_pair do |key, value|
      retval += content_tag("div", check_box_tag('assigned_designations[]', key, has_item(key, user_designations), :class => "checkbox_group", :id => key==1? "student_chk": "chk" + key.to_s) + content_tag("span", value, :class => "checkbox_label"))
    end
    return retval.html_safe
  end

  def origins_div(ethnic_origins)
    retval = ""
    User::ETHNIC_ORIGINS.each_pair do |key, value|
      retval += content_tag("div", check_box_tag('eeo[]', key, has_item(key, ethnic_origins), :class => "checkbox_group") + content_tag("span", value, :class => "checkbox_label"))
    end
    return retval.html_safe
  end

  def link_for_privilege(priv_controller)
      url_for :action => Privilege::ROOT_MENU_ACTIONS[priv_controller], :controller => priv_controller
  end

  def email_button(collection_name)
    case collection_name
    when "users"
      link_to image_tag("email.png") + content_tag(:span, t('common.emaillist')), url_for(action: "message", controller: "users"), :class=>"rightbutton", :remote => true
    else
      ""
    end
  end

  def data_specific_instructions(data_type)
    case data_type
    when "students"
      I18n.t('csv.import.studentinstructions')
    else
      ""
    end
  end

  def helpful_information(help_text)
    text_arr = help_text.split("_")
    return unless current_user.get_user_pref("HELP_" + text_arr[1]).empty?
    displayed_text = text_arr[0]
    if controller_name == "families"
      content_tag("div", 
        link_to(image_tag("close_help.png", :class => "remove_help", :title => I18n.t('help.clicktoremove')), remove_help_user_path(current_user.id, :help_id => text_arr[1]), :remote => true, :id => "remove_help_" + text_arr[1]) <<
          content_tag("p", displayed_text, :class => "helpful_information"), :class => "helpful_background")
    end
  end

  def display_user_column_value(col, user)
    return_val = ""
    case ColumnPreference::AVAILABLE_COLUMNS["users"][col][2]
    when "link"
      return_val = link_to(col=="full_name" ? user.full_name : user[col], edit_user_path(user))
    when "string"
      return_val = col=="full_name" ? user.full_name : user[col]
    when "designations"
      tmp_arr = User::DESIGNATIONS.keys.select {|i| i & (user.designations.nil? ? 0 : user.designations) > 0 }  #=> [1,2,4]
      tmp_arr.each_with_index { |item,index|
        if index>0
          return_val += ", " + User::DESIGNATIONS[item]
        else
          return_val += User::DESIGNATIONS[item]
        end
      }
    else
      return_val = user[col]
    end
    return return_val
  end

  def translated_role(role_name)
    t(role_name, :raise => I18n::MissingTranslationData)
  rescue I18n::MissingTranslationData
    role_name
  end

  def display_add_to_favorites
    case controller_name
      when 'sessions'
      else
        link_to(image_tag("add_favorite.png", size: "18x18", style: "vertical-align:middle;margin-right:5px;margin-bottom:2px;") + content_tag(:span, "Add to Favorites"), add_favorite_user_path(current_user), id: "add_to_favorites", remote: true)
    end
  end
end
