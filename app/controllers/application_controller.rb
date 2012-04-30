class ApplicationController < ActionController::Base
  require 'csv'
  #rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  protect_from_forgery
  layout :layout_by_resource
  before_filter :check_authorization
  before_filter :store_location

  helper_method :current_menu
  helper_method :active_menu_action
  helper_method :sort_direction
  helper_method :sort_column
  helper_method :get_selected_columns
  helper_method :export_csv
  helper_method :left_menu
  helper_method :help_text

  protected
  def layout_by_resource
    if devise_controller? && resource_name == :admin
      "superuser"
    else
      "application"
    end
  end
  
  private
    def help_text
    end

    def left_menu
    end

    def record_not_found
      render :text => "404 Not Found", :status => 404
    end

    # Overwriting the sign_out redirect path method
    def after_sign_out_path_for(resource_or_scope)
      if resource_or_scope == :admin
        new_admin_session_path
      else
        new_user_session_path
      end
    end

    def store_location
      if user_signed_in?
        session[:user_return_to] = request.url unless params[:controller] == "devise/sessions"
      end
    end

    def after_sign_in_path_for(resource_or_scope)
        stored_location_for(resource_or_scope) || root_path
    end

    def check_authorization
    if user_signed_in?
      unless owner?
        unless current_user.can?(controller_name, action_name) 
          redirect_to :back, :flash => { :error => I18n.t('notauthorized') }
        end
      end
    end
  rescue ActionController::RedirectBackError
    redirect_to root_url, :flash => { :error => I18n.t('notauthorized') }
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end

  def sort_column
    @model_array = self.class.name.sub("Controller", "").singularize.split("::")
    @model_name = @model_array[@model_array.length - 1]
    @model_name.constantize.column_names.include?(params[:sort]) ? params[:sort] : "1"
  end

  def current_menu
    if user_signed_in? && current_user.roles
      session[:current_menu] ||= MenuItem.current_menu(current_user)
      return session[:current_menu]
    end
  end

  def get_selected_columns(collection_name)
    selected_columns = ColumnPreference.user_columns(collection_name, current_user.id).map {|i| i.column_name}
    if selected_columns.empty?
      selected_columns = ColumnPreference::AVAILABLE_COLUMNS[collection_name].select {|k,v| v[0] == true}.map {|i| i[0]}
    end
    return selected_columns
  end

  def csv_for(array_of_headers, array_of_records)
    humanized_headers = Array.new
    array_of_headers.each_with_index do |header, i|
      humanized_headers.push(header.humanize)
    end
    (output = "").tap do
      if session[:csv_format].nil? || session[:csv_format].empty? || session[:csv_format] == "Excel"
        CSV.generate(output) do |csv|
          csv << humanized_headers
          array_of_records.each do |record|
            array_of_data = Array.new
            array_of_headers.each do |col|
              array_of_data.push(record.send(col))
            end
            csv << array_of_data
          end
        end
      end
    end
  end

  def export_csv(array_of_headers, array_of_records, filename)
    content = csv_for(array_of_headers, array_of_records)
    if session[:csv_format].nil? || session[:csv_format].empty? || session[:csv_format] == "Excel"
      filename = I18n.l(Time.now, :format => :short) + "-" + filename + ".csv"
      send_data content, :filename => filename, :content_type => 'application/vnd.ms-excel'
    else
      filename = I18n.l(Time.now, :format => :short) + "-" + filename + ".csv"
      send_data content, :filename => filename
    end
  end

end
