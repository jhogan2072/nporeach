class Admin::SubscriptionDiscountsController < ApplicationController
  include Saas::ControllerHelpers
  add_breadcrumb I18n.t('layouts.application.home'), :root_path
  add_breadcrumb I18n.t('admin.subscription_discounts.subscription_discounts'), :admin_subscription_discounts_path
  respond_to :js, :only => :index
  layout 'superuser'

  def update
    update! {admin_subscription_discounts_url}
  end

  def create
    create! {admin_subscription_discounts_url}
  end

  def edit
    add_breadcrumb I18n.t('admin.subscription_discounts.edit.editdiscount'), request.url
    edit!
  end

  def new
    add_breadcrumb I18n.t('admin.subscription_discounts.new.newdiscount'), request.url
    new!
  end
  protected
  
    def collection
     @subscription_discounts ||= end_of_association_chain.search(params[:search]).order(sort_column + ' ' + sort_direction).paginate(:per_page => 15, :page => params[:page])
    end

end
