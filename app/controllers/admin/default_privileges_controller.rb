class Admin::DefaultPrivilegesController < ApplicationController
  include Saas::ControllerHelpers
  add_breadcrumb I18n.t('layouts.application.home'), :admin_subscriptions_path
  add_breadcrumb I18n.t('admin.default_privileges.default_privileges'), :admin_default_privileges_path
  respond_to :js, :only => :index
  helper_method :sort_column
  layout 'superuser'


  def update
    @default_privilege = DefaultPrivilege.find(params[:id])
    @default_privilege.category = Privilege::CONTROLLERS[@default_privilege.controller][0]
    @default_privilege.operations = 0
    @checkboxvalues = params[:allowed_operations]
    @checkboxvalues.each do |value|
      @default_privilege.operations += value.to_i
    end
    update! {admin_default_privileges_url}
  end

  def create
    @default_privilege = DefaultPrivilege.new(params[:default_privilege])
    @default_privilege.category = Privilege::CONTROLLERS[@default_privilege.controller][0]
    @default_privilege.operations = 0
    @checkboxvalues = params[:allowed_operations]
    @checkboxvalues.each do |value|
      @default_privilege.operations += value.to_i
    end
    create! {admin_default_privileges_url}
  end

  def edit
    add_breadcrumb I18n.t('admin.default_privileges.edit.editingdefaultprivilege'), request.url
    edit!
  end

  def new
    add_breadcrumb I18n.t('admin.default_privileges.new.newdefaultprivilege'), request.url
    new!
  end

protected
    def collection
     @default_privileges ||= end_of_association_chain.search(params[:search]).order(sort_column + ' ' + sort_direction).paginate(:per_page => 15, :page => params[:page])
    end

  private
    def sort_column
      DefaultPrivilege.column_names.include?(params[:sort]) ? params[:sort] : "1"
    end

end
