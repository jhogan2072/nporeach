class Admin::SubscriptionsController < ApplicationController
  include Saas::ControllerHelpers
  respond_to :js, :only => :index
  helper_method :sort_column
  add_breadcrumb I18n.t('layouts.application.home'), :admin_subscriptions_path
  layout 'superuser'

  def charge
    if request.post? && !params[:amount].blank?
      if resource.misc_charge(params[:amount])
        flash[:notice] = I18n.t('subscriptionscontroller.cardhasbeencharged')
        redirect_to :action => "show"
      else
        render :action => 'show'
      end
    end
  end

  def show
    add_breadcrumb I18n.t('admin.subscriptions.show.chargesubscription'), request.url
    show!
  end

  def edit
    add_breadcrumb I18n.t('admin.subscriptions.edit.editsubscription'), request.url
    edit!
  end

protected
    def collection
      @stats = SubscriptionPayment.stats if params[:page].blank?
      @subscriptions ||= end_of_association_chain.search(params[:search]).order(sort_column + ' ' + sort_direction).paginate(:include => :subscriber, :per_page => 15, :page => params[:page])
      debugger
    end

  private
    def sort_column
      Subscription.column_names.include?(params[:sort]) ? params[:sort] : "1"
    end
  
end
