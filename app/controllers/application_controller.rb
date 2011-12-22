class ApplicationController < ActionController::Base
  protect_from_forgery
  #before_filter :check_authorization

  helper_method :current_menu

  private

  def check_authorization
    if user_signed_in?
      unless current_admin
        unless current_user.can?(controller_name, action_name) 
          redirect_to :back, :error => I18n.t('notauthorized')
        end
      end
    end
  end

  def current_menu
    if user_signed_in? && current_user.roles
      @roles = current_user.roles.all
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
      debugger
      return @current_menu if defined?(@current_menu)
    end
  end
end
