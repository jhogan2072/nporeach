class Admin::SettingsController < ApplicationController
  include Saas::ControllerHelpers
  add_breadcrumb I18n.t('layouts.application.home'), :root_path
  add_breadcrumb I18n.t('admin.settings.settings'), :admin_settings_path
  respond_to :js, :only => :index
  helper_method :sort_column
  layout 'superuser'

  def update
    update! {admin_settings_url}
  end

  def create
    create! {admin_settings_url}
  end

  def edit
    add_breadcrumb I18n.t('admin.settings.edit.editsetting'), request.url
    edit!
  end

  def new
    add_breadcrumb I18n.t('admin.settings.new.newsetting'), request.url
    new!
  end
  protected

    def collection
     @settings ||= end_of_association_chain.search(params[:search]).order(sort_column + ' ' + sort_direction).paginate(:per_page => 15, :page => params[:page])
    end

  private
    def sort_column
      Setting.column_names.include?(params[:sort]) ? params[:sort] : "1"
    end

end
