class AjaxController < ApplicationController
  def users
    if params[:term]
      like= "%".concat(params[:term].concat("%"))
      users = User.where("last_name like ?", like)
    else
      users = User.all
    end
    list = users.map {|u| Hash[ id: u.id, label: u.full_name, name: u.full_name]}
    render json: list
  end

end
