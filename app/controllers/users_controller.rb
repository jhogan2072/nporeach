class UsersController < InheritedResources::Base
  respond_to :html, :json
  respond_to :js, :csv, :only => [:index, :message]
  before_filter :authenticate_user!
  before_filter :authorized?
  before_filter :check_user_limit, :only => :create
  add_breadcrumb I18n.t('layouts.application.home'), :root_path
  add_breadcrumb I18n.t('users.users'), :users_path
  helper_method :sort_column

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

  def columns
    add_breadcrumb I18n.t('users.columns.editcolumnprefs'), request.url
    @user = current_user
    @collection_name = params[:collection_name]
    if @collection_name.nil? || @collection_name.empty?
      flash["notice"] = I18n.t('columnpreferencescontroller.pagenotavailable')
      redirect_to(root_url)
    end
    ColumnPreference::AVAILABLE_COLUMNS[@collection_name].each_with_index do |(key, val), index|
      current_pref = nil
      current_pref = @user.get_column_prefs(@collection_name).select {|p| p["column_name"] == key}
      if current_pref.nil? || current_pref.empty?
        @user.column_preferences.build(:collection_name => @collection_name, :column_name => key, :column_order => index, :is_displayed => val[0] )
      end
    end
  end

  def update_columns
    @user = current_user
    if params["up"]
      column_prefs = params[:user][:column_preferences_attributes]
      move_up_id = params["up"].to_i
      up_item = column_prefs.find{|key,value| value["column_order"] == move_up_id.to_s}.first
      down_item = column_prefs.find{|key,value| value["column_order"] == (move_up_id - 1).to_s}.first
      column_prefs[up_item]["column_order"] = move_up_id - 1
      column_prefs[down_item]["column_order"] = move_up_id
    end
    if params["down"]
      column_prefs = params[:user][:column_preferences_attributes]
      move_down_id = params["down"].to_i
      down_item = column_prefs.find{|key,value| value["column_order"] == move_down_id.to_s}.first
      up_item = column_prefs.find{|key,value| value["column_order"] == (move_down_id + 1).to_s}.first
      column_prefs[down_item]["column_order"] = move_down_id + 1
      column_prefs[up_item]["column_order"] = move_down_id
    end
    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = I18n.t('userscontroller.preferencesupdated') unless params["up"] || params["down"]
        format.html {redirect_to :back}
      else
        flash[:error] = @user.errors
        format.html {redirect_to :back}
      end
    end
  end

  def index
    @selected_columns = get_selected_columns('users')
    index! do |format|
      format.html
      format.csv do
        @exported_users = current_account.users
        export_csv(@selected_columns, @exported_users, "users")
      end
    end
  end

  def message
    @users = collection
    @sender = current_user
    @message = Message.new
    @addresses = @users.map{|a| a.email}.join(",")
  end

  def print
    @selected_columns = get_selected_columns('users')
    @users = collection
    @page_title = "Users"
    respond_to do |format|
      format.html {render partial: 'shared/print', locals: {output_records: @users, output_columns: @selected_columns, list_style: "user_list"}}
    end
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

    def collection
     @users ||= end_of_association_chain.search(params[:search]).order(sort_column + ' ' + sort_direction).paginate(:per_page => 15, :page => params[:page])
    end
    
    def authorized?
      redirect_to new_user_session_url unless (user_signed_in? && self.action_name == 'index') || owner?
    end
    
    def check_user_limit
      redirect_to new_user_url if current_account.reached_user_limit?
    end

  private
    def sort_column
      User.column_names.include?(params[:sort]) ? params[:sort] : "1"
    end

end
