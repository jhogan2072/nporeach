class ApplicationController < ActionController::Base
  protect_from_forgery
  layout :layout_by_resource
  before_filter :check_authorization

  helper_method :current_menu
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

  def check_authorization
    if user_signed_in?
      unless admin?
        unless current_user.can?(controller_name, action_name) 
          redirect_to :back, :error => I18n.t('notauthorized')
        end
      end
    end
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end

  def current_menu
    if user_signed_in? && current_user.roles
      if current_user.admin?
        @roles = current_account.roles.all
      else
        @roles = current_user.roles.all
      end
      @privileges = []
      @roles.each do |role|
        if role.privileges.all.length > 0
          role.privileges.all.each do |priv|
            @privileges << priv
          end
        end
      end
      if @privileges.length > 0
        @current_menu = @privileges.uniq.group_by {|priv| priv.category}
      end
      return @current_menu if defined?(@current_menu)
    end
  end
end
