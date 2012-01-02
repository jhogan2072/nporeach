class Admin::AccountsController < ApplicationController
  include Saas::ControllerHelpers
  layout 'superuser'
  
  protected
  
    def collection
      @accounts = Account.paginate(:include => :subscription, :page => params[:page], :per_page => 30, :order => 'accounts.name')
    end
  
end
