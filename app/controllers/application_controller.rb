class ApplicationController < ActionController::Base
  protect_from_forgery
  #before_filter :check_authorization

  private

  def check_authorization
    if user_signed_in?
      unless current_user.can?(controller_name, action_name) 
        redirect_to :back, :error => I18n.t('notauthorized')
      end
    end
  end
end
