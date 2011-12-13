class ApplicationController < ActionController::Base
  protect_from_forgery

  layout :layout_by_resource

  def layout_by_resource
    if devise_controller? && resource_name == :user && action_name == 'new'
      "public"
    else
      "application"
    end
  end

end