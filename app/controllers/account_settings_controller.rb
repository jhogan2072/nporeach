class AccountSettingsController < InheritedResources::Base
  add_breadcrumb I18n.t('layouts.application.home'), :root_path
  add_breadcrumb I18n.t('account_settings.accountsettings'), :account_settings_edit_all_path
  respond_to :js, :only => :index
  helper_method :sort_column

  def update_all
    params[:account_settings].each do |account_setting|
      if account_setting["value"] != Setting.find(account_setting["setting_id"]).default_value
        @account_setting = AccountSetting.find(account_setting["id"]) unless account_setting["id"].empty?
        @account_setting ||= AccountSetting.new
        @account_setting.update_attributes(account_setting)
      end
    end
    flash[:notice] = I18n.t('accountsettingscontroller.settingsupdated')
    redirect_to account_settings_edit_all_url
  end

  def edit_all
    default_settings = Setting.all
    @account_settings = Array.new
    current_settings = current_account.account_settings
    default_settings.each do |default_setting|
      cs = nil
      cs = current_settings.select {|f| f["setting_id"] == default_setting.id }
      if cs.length > 0
        @account_settings << cs.first
      else
        @account_settings << AccountSetting.new(:account_id => current_account.id, :setting_id => default_setting.id, :value=> default_setting.default_value)
      end
    end
  end

protected
    def begin_of_association_chain
      current_account
    end

    def collection
     @account_settings ||= end_of_association_chain.search(params[:search]).order(sort_column + ' ' + sort_direction).paginate(:per_page => 15, :page => params[:page])
    end

  private
    def sort_column
      AccountSetting.column_names.include?(params[:sort]) ? params[:sort] : "1"
    end
end
