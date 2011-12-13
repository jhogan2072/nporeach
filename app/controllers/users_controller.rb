class UsersController < InheritedResources::Base
  respond_to :html, :json
  respond_to :js, :only => :create
  before_filter :authenticate_user!
  before_filter :authorized?
  before_filter :check_user_limit, :only => :create
  add_breadcrumb I18n.t('layouts.application.home'), :root_path
  add_breadcrumb I18n.t('users.users'), :users_path

  def create
   create! { users_url }
  end
  
  def update
    update! { users_url }
  end

  def edit
    add_breadcrumb I18n.t('users.edituser'), request.url
    edit!
  end

  def new
    add_breadcrumb I18n.t('users.newuser'), request.url
    new!
  end

  
  protected

    # This is the way to scope everything to the account belonging
    # for the current subdomain in InheritedResources.  This
    # translates into
    # @user = current_account.users.build(params[:user]) 
    # in the new/create actions and
    # @user = current_account.users.find(params[:id]) in the
    # edit/show/destroy actions.
    def begin_of_association_chain
      current_account
    end
    
    def authorized?
      redirect_to new_user_session_url unless (user_signed_in? && self.action_name == 'index') || admin?
    end
    
    def check_user_limit
      redirect_to new_user_url if current_account.reached_user_limit?
    end

end
