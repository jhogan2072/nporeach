class Subscription < ActiveRecord::Base
  belongs_to :subscriber, :polymorphic => true
  belongs_to :subscription_plan
  has_many :subscription_payments
  belongs_to :discount, :class_name => 'SubscriptionDiscount', :foreign_key => 'subscription_discount_id'
  belongs_to :affiliate, :class_name => 'SubscriptionAffiliate', :foreign_key => 'subscription_affiliate_id'
  
  before_create :set_renewal_at
  before_update :apply_discount
  before_destroy :destroy_gateway_record
  
  attr_accessor :creditcard, :address
  attr_reader :response
  
  # renewal_period is the number of months to bill at a time
  # default is 1
  validates_numericality_of :renewal_period, :only_integer => true, :greater_than => 0
  validates_numericality_of :amount, :greater_than_or_equal_to => 0
  validate :card_storage, :on => :create
  validate :within_limits, :on => :update
  
  #
  # Changes the subscription plan, and assigns various properties, 
  # such as limits, etc., to the subscription from the assigned 
  # plan.  
  #
  # When adding new limits that are specified in SubscriptionPlan, 
  # if you name them like "some_quantity_limit", they will automatically
  # be used by this method.
  #
  # Otherwise, you'll need to manually add the assignment to this method.
  #
  def plan=(plan)
    if plan.amount > 0
      # Discount the plan with the existing discount (if any)
      # if the plan doesn't already have a better discount
      plan.discount = discount if discount && discount > plan.discount
      # If the assigned plan has a better discount, though, then
      # assign the discount to the subscription so it will stick
      # through future plan changes
      self.discount = plan.discount if plan.discount && plan.discount > discount
    else
      # Free account from the get-go?  No point in having a trial
      self.state = 'active' if new_record?
    end

    #
    # Find any attributes that exist in both the Subscription and SubscriptionPlan
    # and that match the pattern of "something_limit"
    #
    limits = self.attributes.keys.select { |k| k =~ /^.+_limit$/ } &
             plan.attributes.keys.select { |k| k =~ /^.+_limit$/ }

    (limits + [:amount, :renewal_period]).each do |f|
      self.send("#{f}=", plan.send(f))
    end
    
    self.subscription_plan = plan
  end
  
  # The plan_id and plan_id= methods are convenience methods for the
  # administration interface.
  def plan_id
    subscription_plan_id
  end
  
  def plan_id=(a_plan_id)
    self.plan = SubscriptionPlan.find(a_plan_id) if a_plan_id.to_i != subscription_plan_id
  end
  
  def trial_days
    (self.next_renewal_at.to_i - Time.now.to_i) / 86400
  end
  
  def amount_in_pennies
    (amount * 100).to_i
  end
  
  def store_card(creditcard, gw_options = {})
    # Clear out payment info if switching to CC from PayPal
    destroy_gateway_record(paypal) if paypal?
    
    @response = if billing_id.blank?
      gateway.store(creditcard, gw_options)
    else
      gateway.update(billing_id, creditcard, gw_options)
    end
    
    if @response.success?
      self.card_number = creditcard.display_number
      self.card_expiration = "%02d-%d" % [creditcard.expiry_date.month, creditcard.expiry_date.year]
      set_billing
    else
      errors.add(:base, @response.message)
      false
    end
  end
  
  # Charge the card on file the amount stored for the subscription
  # record.  This is called by the daily_mailer script for each 
  # subscription that is due to be charged.  A SubscriptionPayment
  # record is created, and the subscription's next renewal date is 
  # set forward when the charge is successful.
  # 
  # If this subscription is paid via paypal, check to see if paypal
  # made the charge and set the billing date into the future.
  def charge
    if paypal?
      if (@response = paypal.get_profile_details(billing_id)).success?
        next_billing_date = Time.parse(@response.params['next_billing_date'])
        if next_billing_date > Time.now.utc
          update_attributes(:next_renewal_at => next_billing_date, :state => 'active')
          subscription_payments.create(:subscriber => subscriber, :amount => amount) unless amount == 0
          true
        else
          false
        end
      else
        errors.add(:base, @response.message)
        false
      end
    else
      if amount == 0 || (@response = gateway.purchase(amount_in_pennies, billing_id)).success?
        update_attributes(:next_renewal_at => self.next_renewal_at.advance(:months => self.renewal_period), :state => 'active')
        subscription_payments.create(:subscriber => subscriber, :amount => amount, :transaction_id => @response.authorization) unless amount == 0
        true
      else
        errors.add(:base, @response.message)
        false
      end
    end
  end
  
  # Charge the card on file any amount you want.  Pass in a dollar
  # amount (1.00 to charge $1).  A SubscriptionPayment record will
  # be created, but the subscription itself is not modified.
  def misc_charge(amount)
    if amount == 0 || (@response = gateway.purchase((amount.to_f * 100).to_i, billing_id)).success?
      subscription_payments.create(:subscriber => subscriber, :amount => amount, :transaction_id => @response.authorization, :misc => true)
      true
    else
      errors.add(:base, @response.message)
      false
    end
  end
  
  def start_paypal(return_url, cancel_url)
    if (@response = paypal.setup_agreement(:return_url => return_url, :cancel_return_url => cancel_url, :description => Saas::Config.app_name)).success?
      paypal.redirect_url_for(@response.params['token'])
    else
      errors.add(:base, "PayPal Error: #{@response.message}")
      false
    end
  end
  
  def complete_paypal(token)
    # Make sure the paypal subscription gets started tomorrow at the 
    # earliest
    start_date = next_renewal_at < 1.day.from_now.at_beginning_of_day ? 1.day.from_now : next_renewal_at
    
    if (@response = paypal.create_profile(token, :description => Saas::Config.app_name, :start_date => start_date, :frequency => renewal_period, :amount => amount_in_pennies)).success?

      # Clear out payment info if changing the PayPal billing
      # info or if switching from a CC
      if paypal?
        destroy_gateway_record(paypal)
      else
        destroy_gateway_record(cc)
      end

      self.card_number = 'PayPal'
      self.card_expiration = 'N/A'
      self.state = 'active'
      self.billing_id = @response.params['profile_id']
      # Sync up our next renewal date with PayPal.
      self.next_renewal_at = Time.parse(paypal.get_profile_details(@response.params['profile_id']).params['next_billing_date'])
      save
    else
      errors.add(:base, "PayPal Error: #{@response.message}")
      false
    end
  end
  
  def needs_payment_info?
    self.card_number.blank? && self.subscription_plan.amount > 0
  end
  
  def self.find_expiring_trials(renew_at = 7.days.from_now)
    find(:all, :include => :subscriber, :conditions => { :state => 'trial', :next_renewal_at => (renew_at.beginning_of_day .. renew_at.end_of_day) })
  end
  
  def self.find_due_trials(renew_at = Time.now)
    find(:all, :include => :subscriber, :conditions => { :state => 'trial', :next_renewal_at => (renew_at.beginning_of_day .. renew_at.end_of_day) }).select {|s| !s.card_number.blank? }
  end
  
  def self.find_due(renew_at = Time.now)
    find(:all, :include => :subscriber, :conditions => { :state => 'active', :next_renewal_at => (renew_at.beginning_of_day .. renew_at.end_of_day) })
  end
  
  def paypal?
    card_number == 'PayPal'
  end
  
  def current?
    next_renewal_at >= Time.now
  end
  
  def purge_paypal
    return true if billing_id.blank?
    if (@response = paypal.unstore(billing_id)).success?
      clear_billing_info
      return save
    else
      errors.add(:base, @response.message)
      return false
    end
  end

  def self.search(search)
    if search #&& column_name && self.column_names.include?(column_name)
      where('account.name LIKE ?', "%#{search}%")
    else
      scoped
    end
  end

  protected
  
    def set_billing

      self.billing_id = @response.token

      if new_record?
        if !next_renewal_at? || next_renewal_at < 1.day.from_now.at_midnight
          if subscription_plan.trial_period?
            self.next_renewal_at = Time.now.advance(:months => subscription_plan.trial_period)
          else
            charge_amount = subscription_plan.setup_amount? ? subscription_plan.setup_amount : amount
            if (@response = gateway.purchase(charge_amount * 100, billing_id)).success?
              subscription_payments.build(:subscriber => subscriber, :amount => charge_amount, :transaction_id => @response.authorization, :setup => subscription_plan.setup_amount?)
              self.state = 'active'
              self.next_renewal_at = Time.now.advance(:months => renewal_period)
            else
              errors.add(:base, @response.message)
              return false
            end
          end
        end
      else
        if !next_renewal_at? || next_renewal_at < 1.day.from_now.at_midnight
          if (@response = gateway.purchase(amount_in_pennies, billing_id)).success?
            subscription_payments.build(:subscriber => subscriber, :amount => amount, :transaction_id => @response.authorization)
            self.state = 'active'
            self.next_renewal_at = Time.now.advance(:months => renewal_period)
          else
            errors.add(:base, @response.message)
            return false
          end
        else
          self.state = 'active'
        end
        self.save
      end
    
      true
    end
    
    def set_renewal_at
      return if self.subscription_plan.nil? || self.next_renewal_at
      self.next_renewal_at = Time.now.advance(:months => self.renewal_period)
    end
    
    # If the discount is changed, set the amount to the discounted
    # plan amount with the new discount.
    def apply_discount
      if subscription_discount_id_changed?
        subscription_plan.discount = discount
        self.amount = subscription_plan.amount
      end
    end
    
    def gateway
      paypal? ? paypal : cc
    end
    
    def paypal
      @paypal ||=  ActiveMerchant::Billing::Base.gateway(:paypal_express_recurring).new(Saas::Config.credentials['paypal'])
    end
    
    def cc
      @cc ||= ActiveMerchant::Billing::Base.gateway(Saas::Config.gateway).new(Saas::Config.credentials['gateway'])
    end

    def destroy_gateway_record(gw = paypal? ? paypal : gateway)
      return if billing_id.blank?
      gw.unstore(billing_id)
      clear_billing_info
    end
    
    def clear_billing_info
      self.card_number = nil
      self.card_expiration = nil
      self.billing_id = nil
    end
    
    def card_storage
      self.store_card(@creditcard, :billing_address => @address.to_activemerchant) if @creditcard && @address && card_number.blank?
    end
    
    def within_limits
      return unless subscription_plan_id_changed?
      subscriber.class.subscription_limits.each do |limit, rule|
        unless (cap = subscription_plan.send(limit)).nil? || rule.call(subscriber) <= cap
          errors.add(:base, "#{limit.to_s.humanize} for new plan would be exceeded.")
        end
      end
      
    end
end
