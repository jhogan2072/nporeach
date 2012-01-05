class Admin::SubscriptionPlansController < ApplicationController
  include Saas::ControllerHelpers
  add_breadcrumb I18n.t('layouts.application.home'), :admin_subscriptions_path
  add_breadcrumb I18n.t('admin.subscription_plans.subscription_plans'), :admin_subscription_plans_path
  respond_to :js, :only => :index
  helper_method :sort_column
  layout 'superuser'

  def update
    update! {admin_subscription_plans_url}
  end

  def create
    create! {admin_subscription_plans_url}
  end

  def edit
    add_breadcrumb I18n.t('admin.subscription_plans.edit.editplan'), request.url
    edit!
  end

  def new
    add_breadcrumb I18n.t('admin.subscription_plans.new.newplan'), request.url
    new!
  end
  protected
  
    #def resource
    #  @subscription_plan ||= SubscriptionPlan.find_by_name!(params[:id])
    #end
    
    def collection
     @subscription_plans ||= end_of_association_chain.search(params[:search]).order(sort_column + ' ' + sort_direction).paginate(:per_page => 15, :page => params[:page])
    end

  private
    def sort_column
      SubscriptionPlan.column_names.include?(params[:sort]) ? params[:sort] : "1"
    end
end
