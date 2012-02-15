class Admin::DefaultRolesController < ApplicationController
  include Saas::ControllerHelpers
  add_breadcrumb I18n.t('layouts.application.home'), :root_path
  add_breadcrumb I18n.t('admin.default_roles.default_roles'), :admin_default_roles_path
  respond_to :js, :only => :index
  layout 'superuser'

  def create
    @privileges = populate_privileges
    create! { admin_default_roles_url }
  end

  def update
    @privileges = populate_privileges
    update! {admin_default_roles_url}
  end

  def edit
    @default_role = DefaultRole.find(params[:id])
    add_breadcrumb I18n.t('admin.default_roles.edit.editingdefaultrole'), request.url
    @privileges = populate_privileges
    edit!
  end

  def new
    @default_role = DefaultRole.new
    add_breadcrumb I18n.t('admin.default_roles.new.newdefaultrole'), request.url
    @privileges = populate_privileges
    new!
  end

  protected
  def collection
    @default_roles ||= end_of_association_chain.search(params[:search]).order(sort_column + ' ' + sort_direction).paginate(:per_page => 15, :page => params[:page])
  end

  def populate_privileges
    priv_array = []
    if Privilege.all.length > 0
        Privilege.all.each do |priv|
        priv_array << priv
      end
    end
    return priv_array.group_by {|priv| priv.category}
  end

end
