class Admin::PrivilegesController < ApplicationController
  include Saas::ControllerHelpers
  add_breadcrumb I18n.t('layouts.application.home'), :root_path
  add_breadcrumb I18n.t('admin.privileges.privileges'), :admin_privileges_path
  respond_to :js, :only => :index
  layout 'superuser'

  def update_actions
    @privilege = Privilege.new
    param_controller = params[:name]
    @privilege.controller = param_controller
    render :partial => 'actions', :locals => {:privilege => @privilege}
  end

  def update
    @privilege = Privilege.find(params[:id])
    @privilege.actions = 0
    @checkboxvalues = params[:allowed_actions]
    @checkboxvalues.each do |value|
      @privilege.actions += value.to_i
    end
    update! {admin_privileges_url}
  end

  def create
    @privilege = Privilege.new(params[:privilege])
    @privilege.actions = 0
    @checkboxvalues = params[:allowed_actions]
    @checkboxvalues.each do |value|
      @privilege.actions += value.to_i
    end
    create! {admin_privileges_url}
  end

  def edit
    add_breadcrumb I18n.t('admin.privileges.edit.editingprivilege'), request.url
    edit!
  end

  def new
    add_breadcrumb I18n.t('admin.privileges.new.newprivilege'), request.url
    new!
  end

protected
    def collection
     @privileges ||= end_of_association_chain.search(params[:search]).order(sort_column + ' ' + sort_direction).paginate(:per_page => 15, :page => params[:page])
    end

end
