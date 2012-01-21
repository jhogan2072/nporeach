class ApplicationController < ActionController::Base
  #rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  protect_from_forgery
  layout :layout_by_resource
  before_filter :check_authorization
  before_filter :store_location

  helper_method :current_menu
  helper_method :active_menu_action
  helper_method :sort_direction

  protected
  def layout_by_resource
    if devise_controller? && resource_name == :admin
      "superuser"
    else
      "application"
    end
  end
  
  private
    def record_not_found
      render :text => "404 Not Found", :status => 404
    end

    # Overwriting the sign_out redirect path method
    def after_sign_out_path_for(resource_or_scope)
      if resource_or_scope == :admin
        new_admin_session_path
      else
        new_user_session_path
      end
    end

    def store_location
      if user_signed_in?
        session[:user_return_to] = request.url unless params[:controller] == "devise/sessions"
      end
    end

    def after_sign_in_path_for(resource_or_scope)
        stored_location_for(resource_or_scope) || root_path
    end

    def check_authorization
    if user_signed_in?
      unless owner?
        unless current_user.can?(controller_name, action_name) 
          redirect_to :back, :flash => { :error => I18n.t('notauthorized') }
        end
      end
    end
  rescue ActionController::RedirectBackError
    redirect_to root_url, :flash => { :error => I18n.t('notauthorized') }
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end

  def current_menu
    if user_signed_in? && current_user.roles
      session[:current_menu] ||= MenuItem.current_menu(current_user)
      return session[:current_menu]
    end
  end

  def active_menu_action
    active_action = nil
    action_present = false
    current_menu.each do |key, value|
      item_found = value.any? { |menu_item| (menu_item.controller == controller_name && menu_item.action == action_name) }
      action_present = true if item_found
    end    
    active_action = action_name if action_present
    return active_action
  end
end
