class Admin::MenuItemsController < ApplicationController
  include Saas::ControllerHelpers
  add_breadcrumb I18n.t('layouts.application.home'), :root_path
  add_breadcrumb I18n.t('admin.menu_items.menu_items'), :admin_menu_items_path
  respond_to :js, :only => [:index, :add_child]
  layout 'superuser'

  def update
    update! {admin_menu_items_url}
  end

  def create
    create! {admin_menu_items_url}
  end

  def edit
    add_breadcrumb I18n.t('admin.menu_items.edit.editmenu_item'), request.url
    edit!
  end

  def new
    add_breadcrumb I18n.t('admin.menu_items.new.newmenu_item'), request.url
    new!
  end

protected

    def collection
     @menu_items ||= end_of_association_chain.search(params[:search]).order(sort_column + ' ' + sort_direction).paginate(:per_page => 15, :page => params[:page])
    end

end
