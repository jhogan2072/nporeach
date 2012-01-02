module ApplicationHelper
  def flash_notices
    raw([:notice, :error, :alert].collect {|type| content_tag('div', flash[type], :id => type) if flash[type] }.join)
  end
  
  # Render a submit button and cancel link
  def submit_or_cancel(cancel_url = session[:return_to] ? session[:return_to] : url_for(:action => 'index'), label = 'Save Changes')
    raw(content_tag(:div, submit_tag(label) + ' or ' +
      link_to('Cancel', cancel_url), :id => 'submit_or_cancel', :class => 'submit'))
  end

  def discount_label(discount)
    (discount.percent? ? number_to_percentage(discount.amount * 100, :precision => 0) : number_to_currency(discount.amount)) + ' off'
  end

  def hide_ul_if(condition, attributes = {}, &block)
    if condition
      attributes["style"] = "display: none"
    end
    content_tag("ul", attributes, &block)
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

  def link_for_privilege(priv_controller)
  debugger
    if priv_controller == "accounts"
      url_for :action => 'show', :controller => 'accounts'
    else
      url_for :controller => priv_controller
    end
  end

end
