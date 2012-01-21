class Admin::AccountsController < ApplicationController
  include Saas::ControllerHelpers
  respond_to :js, :only => :index
  helper_method :sort_column
  add_breadcrumb I18n.t('layouts.application.home'), :root_path
  add_breadcrumb I18n.t('admin.accounts.accounts'), :admin_accounts_path
  layout 'superuser'
  
  def update
    update! {admin_accounts_url}
  end

  def create
    create! {admin_accounts_url}
  end

  def edit
    add_breadcrumb I18n.t('admin.accounts.edit.editaccount'), request.url
    edit!
  end

  def new
    add_breadcrumb I18n.t('admin.accounts.new.newaccount'), request.url
    new!
  end

  protected
  
    def collection
      @accounts ||= end_of_association_chain.search(params[:search]).order(sort_column + ' ' + sort_direction).paginate(:per_page => 30, :page => params[:page])
    end

  private
    def sort_column
      Account.column_names.include?(params[:sort]) ? params[:sort] : "1"
    end
  
end
