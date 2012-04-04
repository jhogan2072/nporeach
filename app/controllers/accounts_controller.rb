class AccountsController < InheritedResources::Base
  before_filter :authenticate_user!, :except => [ :new, :create, :plans, :canceled, :thanks, :siteaddress, :loginredirect]
  #before_filter :authorized?, :except => [ :new, :create, :plans, :canceled, :thanks, :siteaddress, :loginredirect]
  before_filter :build_user, :only => [:new, :create]
  before_filter :load_billing, :only => [ :new, :create, :billing, :paypal ]
  before_filter :load_subscription, :only => [ :billing, :plan, :paypal, :plan_paypal ]
  before_filter :load_discount, :only => [ :plans, :plan, :new, :create ]
  before_filter :build_plan, :only => [:new, :create]
  add_breadcrumb I18n.t('layouts.application.home'), :root_path
  add_breadcrumb I18n.t('accounts.account'), :account_path
  layout :resolve_layout
  # ssl_required :billing, :cancel, :new, :create
  # ssl_allowed :plans, :thanks, :canceled, :paypal

  def change_owner
    @account = current_account
    if request.post? || request.put?
      #Make the change to the users involved
      previous_owner = User.find(params[:account][:current_owner_id])
      new_owner = User.find(params[:account][:owner_id])
      if
        previous_owner.update_attribute(:owner, false) && new_owner.update_attribute(:owner, true)
        flash[:notice] = I18n.t('accountscontroller.accountupdated') + " - " + I18n.t('accountscontroller.newowneris') + ": " + params[:account][:owner_full_name]
        redirect_to root_url
      else
        render :action => 'change_owner'
      end
    end
  end

  # The siteaddress action just redirects to a page that will prompt the user for their site address then redirect them to their login page
  def siteaddress
    render :layout => 'public' # Uncomment if your "public" site has a different layout than the one used for logged-in users
  end

  def loginredirect
    redirect_to url_for("http://" << params[:siteaddress] << "." << Saas::Config.base_domain)
  end

  def new
    render :layout => 'public' # Uncomment if your "public" site has a different layout than the one used for logged-in users
  end
  
  def settings
    add_breadcrumb I18n.t('accounts.settings.editaccountsetting'), request.url
    default_settings = Setting.order('id')
    @account = current_account
    default_settings.each do |default_setting|
      cs = nil
      cs = @account.account_settings.select {|f| f["setting_id"] == default_setting.id }
      if cs.nil? || cs.length == 0
        @account.account_settings.build(:account_id => current_account.id, :setting_id => default_setting.id, :value=> default_setting.default_value)
      end
    end
  end

  def update_settings
    @account = current_account
    respond_to do |format|
      if @account.update_attributes(params[:account])
        flash[:notice] = I18n.t('accountscontroller.settingsupdated')
        format.html {redirect_to accounts_settings_url}
      else
        flash[:error] = @account.errors
        format.html {redirect_to accounts_settings_url}
      end
    end
  end

  def update_mylinks
    @user = current_user
    respond_to do |format|
      if @user.update_attributes(params[:account])
        flash[:notice] = I18n.t('accountscontroller.settingsupdated')
        format.html {redirect_to accounts_settings_url}
      else
        flash[:error] = @account.errors
        format.html {redirect_to accounts_settings_url}
      end
    end
  end

  def create
    @account.affiliate = SubscriptionAffiliate.find_by_token(cookies[:affiliate]) unless cookies[:affiliate].blank?

    if @account.needs_payment_info?
      @address.first_name = @creditcard.first_name
      @address.last_name = @creditcard.last_name
      @account.address = @address
      @account.creditcard = @creditcard
    end
    
    if @account.save
      flash[:domain] = @account.domain
      redirect_to thanks_url
    else
      render :action => 'new', :layout => 'public' # Uncomment if your "public" site has a different layout than the one used for logged-in users
    end
  end

  def edit
    add_breadcrumb I18n.t('accounts.edit.editorganization'), request.url
    edit!
  end
  
  def update
    if resource.update_attributes(params[:account])
      flash[:notice] = I18n.t('accountscontroller.accountupdated')
      redirect_to redirect_url
    else
      render :action => 'edit'
    end
  end
  
  def plans
    @plans = SubscriptionPlan.find(:all, :order => 'amount desc').collect {|p| p.discount = @discount; p.description = t(p.description); p }
    render :layout => 'public' # Uncomment if your "public" site has a different layout than the one used for logged-in users
  end
  
  def billing
    add_breadcrumb I18n.t('accounts.billing.billinginformation'), request.url
    if request.post?
      if params[:paypal].blank?
        @address.first_name = @creditcard.first_name
        @address.last_name = @creditcard.last_name
        if @creditcard.valid? & @address.valid?
          if @subscription.store_card(@creditcard, :billing_address => @address.to_activemerchant, :ip => request.remote_ip)
            flash[:notice] = I18n.t('accountscontroller.billingupdated')
            redirect_to :action => "billing"
          end
        end
      else
        if redirect_url = @subscription.start_paypal(paypal_account_url, billing_account_url)
          redirect_to redirect_url
        end
      end
    end
  end
  
  # Handle the redirect return from PayPal
  def paypal
    if params[:token]
      if @subscription.complete_paypal(params[:token])
        flash[:notice] = I18n.t('accountscontroller.billingupdated')
        redirect_to :action => "billing"
      else
        render :action => 'billing'
      end
    else
      redirect_to :action => "billing"
    end
  end

  def plan
    add_breadcrumb I18n.t('accounts.plan.changeplan'), request.url
    if request.post?
      @subscription.plan = SubscriptionPlan.find(params[:plan_id])

      # PayPal subscriptions must get redirected to PayPal when
      # changing the plan because a new recurring profile needs
      # to be set up with the new charge amount.
      if @subscription.paypal?
        # Purge the existing payment profile if the selected plan is free
        if @subscription.amount == 0
          logger.info "FREE"
          if @subscription.purge_paypal
            logger.info "PAYPAL"
            flash[:notice] = I18n.t('accountscontroller.subscriptionchanged')
            SubscriptionNotifier.plan_changed(@subscription).deliver
          else
            flash[:error] = I18n.t('accountscontroller.errordeletingpaypal') << "#{@subscription.errors.full_messages.to_sentence}"
          end
          redirect_to :action => "plan" and return
        else
          if redirect_url = @subscription.start_paypal(plan_paypal_account_url(:plan_id => params[:plan_id]), plan_account_url)
            redirect_to redirect_url and return
          else
            flash[:error] = @subscription.errors.full_messages.to_sentence
            redirect_to :action => "plan" and return
          end
        end
      end
      
      if @subscription.save
        flash[:notice] = I18n.t('accountscontroller.subscriptionchanged')
        SubscriptionNotifier.plan_changed(@subscription).deliver
      else
        flash[:error] = I18n.t('accountscontroller.errorupdatingplan') << "#{@subscription.errors.full_messages.to_sentence}"
      end
      redirect_to :action => "plan"
    else
      @plans = SubscriptionPlan.find(:all, :conditions => ['id <> ?', @subscription.subscription_plan_id], :order => 'amount desc').collect {|p| p.discount = @subscription.discount; p }
    end
  end
  
  # Handle the redirect return from PayPal when changing plans
  def plan_paypal
    if params[:token]
      @subscription.plan = SubscriptionPlan.find(params[:plan_id])
      if @subscription.complete_paypal(params[:token])
        flash[:notice] = I18n.t('accountscontroller.subscriptionchanged')
        SubscriptionNotifier.plan_changed(@subscription).deliver
        redirect_to :action => "plan"
      else
        flash[:error] = I18n.t('accountscontroller.errorcompletingpaypal') << "#{@subscription.errors.full_messages.to_sentence}"
        redirect_to :action => "plan"
      end
    else
      redirect_to :action => "plan"
    end
  end

  def cancel
    add_breadcrumb I18n.t('accounts.cancel.cancelaccount'), request.url
    if request.post? and !params[:confirm].blank?
      current_account.destroy
      sign_out(:user)
      redirect_to :action => "canceled"
    end
  end
  
  def thanks
    redirect_to :action => "plans" and return unless flash[:domain]
    render :layout => 'public' # Uncomment if your "public" site has a different layout than the one used for logged-in users
  end
  
  def dashboard
    add_breadcrumb I18n.t('accountscontroller.dashboard'), request.url
    @user = current_user
    @common_links = Array.new
    if session[:user_links].nil?
      current_menu.each do |category, menu_items|
        menu_items.each do |m|
          @common_links << [t(m.help_text), url_for(:action => m.action, :controller => m.controller)]
        end
      end
    else
      session[:user_links].each do |link|
        @common_links << [link[0], link[1]]
      end
    end
  end

  protected
  
    def resource
      @account ||= current_account
    end
    
    def build_user
      build_resource.owner = User.new unless build_resource.owner
    end
    
    def build_plan
      redirect_to :action => "plans" unless @plan = SubscriptionPlan.find(params[:plan])
      @plan.discount = @discount
      @account.plan = @plan
    end
    
    def redirect_url
      { :action => 'show' }
    end
    
    def load_billing
      @creditcard = ActiveMerchant::Billing::CreditCard.new(params[:creditcard])
      @address = SubscriptionAddress.new(params[:address])
    end

    def load_subscription
      @subscription = current_account.subscription
    end
    
    # Load the discount by code, but not if it's not available
    def load_discount
      if params[:discount].blank? || !(@discount = SubscriptionDiscount.find_by_code(params[:discount])) || !@discount.available?
        @discount = nil
      end
    end

private
  def resolve_layout
    case action_name
    when 'siteaddress'
      'public'
    when 'new'
      'public'
    when 'plans'
      'public'
    when 'thanks'
      'public'
    when 'edit'
      'two_column'
    when 'plan'
      'two_column'
    when 'billing'
      'two_column'
    when 'cancel'
      'two_column'
    else
      'application'
    end
  end

  def left_menu
    menu_array = Array.new
    menu_array << [t('accounts.show.editaccountinformation'), edit_account_url, nil]
    menu_array << [t('accounts.show.changebillingplan'), plan_account_url, nil]
    menu_array << [t('accounts.show.editpaymentinfo'), billing_account_url, nil]
    menu_array << [t('accounts.show.importdata'), csv_import_url, nil]
    menu_array << [t('accounts.show.cancelplan'), cancel_account_url, nil]
  end

end
