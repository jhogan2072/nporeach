class RolesController < InheritedResources::Base
  add_breadcrumb I18n.t('layouts.application.home'), :root_path
  add_breadcrumb I18n.t('roles.roles'), :roles_path

  def edit
    add_breadcrumb I18n.t('roles.editrole'), request.url
    edit!
  end

  def new
    add_breadcrumb I18n.t('roles.newrole'), request.url
    new!
  end

protected
    def begin_of_association_chain
      @current_account
    end
end
