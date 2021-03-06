class Admin::SubscriptionAffiliatesController < ApplicationController
  include Saas::ControllerHelpers
  add_breadcrumb I18n.t('layouts.application.home'), :root_path
  add_breadcrumb I18n.t('admin.subscription_affiliates.subscription_affiliates'), :admin_subscription_affiliates_path
  respond_to :js, :only => :index
  layout 'superuser'

  def update
    update! {admin_subscription_affiliates_url}
  end

  def create
    create! {admin_subscription_affiliates_url}
  end

  def edit
    add_breadcrumb I18n.t('admin.subscription_affiliates.edit.editaffiliate'), request.url
    edit!
  end

  def new
    add_breadcrumb I18n.t('admin.subscription_affiliates.new.newaffiliate'), request.url
    new!
  end
  protected
  
    def collection
     @subscription_affiliates ||= end_of_association_chain.search(params[:search]).order(sort_column + ' ' + sort_direction).paginate(:per_page => 15, :page => params[:page])
    end

end
