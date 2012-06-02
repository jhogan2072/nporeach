class UsersController < InheritedResources::Base
  respond_to :html, :json
  respond_to :js, :csv, :only => [:index, :message, :remove_help, :credentials]
  before_filter :authenticate_user!
  before_filter :authorized?
  before_filter :check_user_limit, :only => :create
  add_breadcrumb I18n.t('layouts.application.home'), :root_path
  layout :resolve_layout

  def create
    @user = current_account.users.build(params[:user])
    @user.designations = 0
    @user.ethnic_origin = 0
    @originvalues = params[:eeo]
    @originvalues.each do |value|
      @user.ethnic_origin += value.to_i
    end
    @designationvalues = params[:assigned_designations]
    @designationvalues.each do |value|
      @user.designations += value.to_i
    end
    create!(:notice => I18n.t('users.form.successfulcreation')) do |success, failure|
      success.html { redirect_to members_family_path(params[:user][:family_id]) }
      failure.html do
        flash[:family_id] = params[:user][:family_id]
        render :action => 'new'
      end
    end
  end
  
  def update
    @user = current_account.users.find(params[:id])
    @user.designations = 0
    @user.ethnic_origin = 0
    @originvalues = params[:eeo]
    @originvalues.each do |value|
      @user.ethnic_origin += value.to_i
    end
    @designationvalues = params[:assigned_designations]
    @designationvalues.each do |value|
      @user.designations += value.to_i
    end
    update!(:notice => I18n.t('users.form.successfulupdate')) { members_family_path(@user.family_id) }
  end

  def edit
    if request.referer && request.referer.index('my_family')
      add_breadcrumb I18n.t('families.myfamily'), request.referer
    else
      add_breadcrumb I18n.t('families.families'), :families_path
    end
    add_breadcrumb I18n.t('users.edituser'), request.url
    @family_name = User.find(params["id"].to_i).family.name
    @form_title = I18n.t('users.form.addafamilymember') + " - " + @family_name + " " + I18n.t('familymodel.modelname')
    @password_title = I18n.t('users.passwords.resetuserspassword')
    edit!
  end

  def profile
    add_breadcrumb I18n.t('users.profile.edityourprofile'), request.url
    @form_title = I18n.t('users.profile.edityourprofile')
    @user = current_user
  end

  def password
    add_breadcrumb I18n.t('users.passwords.changeyourpassword'), request.url
    @password_title = I18n.t('users.passwords.changeyourpassword')
    @user = current_user
  end

  def new
    if request.referer && request.referer.index('my_family')
      add_breadcrumb I18n.t('families.myfamily'), request.referer
    else
      add_breadcrumb I18n.t('families.families'), :families_path
    end
    add_breadcrumb I18n.t('users.newfamilymember'), request.url
    @family_name = params["fid"]? Family.find(params["fid"].to_i).name : ""
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

  def dashboard
    @user = current_user
    @my_links = Array.new
    if @user.get_user_pref('MY_LINKS').blank?
      current_menu.each do |category, menu_items|
        menu_items.each do |m|
          @my_links << @user.user_preferences.new(:pref_key => "MY_LINKS", :pref_value => t(m[2]) + "#" + url_for(:action => m[1], :controller => m[0]))
        end
      end
    else
      @my_links = @user.get_user_pref('MY_LINKS').to_a()
    end
  end

  def update_mylinks
    @user = current_user
    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = I18n.t('accountscontroller.settingsupdated')
        format.html {redirect_to dashboard_user_url}
      else
        flash[:error] = @user.errors
        format.html {redirect_to dashboard_user_url}
      end
    end
  end

  def remove_help
    false_value = Array.new(1, "0")
    @help_id = params["help_id"]
    current_user.set_user_pref('HELP_' + @help_id, false_value)
  end

  def index
    add_breadcrumb I18n.t('users.systemusers'), request.url
    @selected_columns = get_selected_columns('users')
    #display only the people that have logins into the system
    @users = collection.where("encrypted_password is not null")
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
   @users ||= end_of_association_chain.search(params[:search]).order(order_by_column + ' ' + sort_direction).paginate(:per_page => 15, :page => params[:page])
  end

  def authorized?
    redirect_to new_user_session_url unless (user_signed_in? && self.action_name == 'index') || owner?
  end

  def check_user_limit
    redirect_to new_user_url if current_account.reached_user_limit?
  end

private
  def order_by_column
    User.column_names.include?(params[:sort]) ? params[:sort] : "last_name"
  end

  def sort_column
    User.column_names.include?(params[:sort]) ? params[:sort] : params[:sort] == "full_name" ? params[:sort] : "1"
  end

  def resolve_layout
    case action_name
      when 'index'
        if get_selected_columns('users').length > 4
          'hybrid'
        else
          'two_column'
        end
      else
        'application'
    end
  end

  def left_menu
    menu_array = Array.new
    menu_array << [t('families.menu.importfamilies'), url_for(csv_import_path(:data => "students"))]
    menu_array << [t('families.menu.viewfamilies'), url_for(families_path)]
    menu_array << [t('families.menu.managesystemusers'), url_for(users_path)]
  end

end
