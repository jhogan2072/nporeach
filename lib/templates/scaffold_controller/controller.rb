class <%= controller_class_name %>Controller < InheritedResources::Base
  add_breadcrumb I18n.t('layouts.application.home'), :root_path
  add_breadcrumb I18n.t('<%= controller_class_name.downcase %>.<%= controller_class_name.downcase %>'), :<%= controller_class_name.downcase %>_path
  respond_to :js, :only => :index
  helper_method :sort_column
<% if options[:singleton] -%>
  defaults :singleton => true
<% end -%>

  def create
    create! { <%= controller_class_name.downcase %>_url }
  end

  def update
    update! {<%= controller_class_name.downcase %>_url}
  end

  def edit
    add_breadcrumb I18n.t('<%= controller_class_name.downcase %>.edit<%= controller_class_name.downcase.singularize %>'), request.url
    edit!
  end

  def new
    add_breadcrumb I18n.t('<%= controller_class_name.downcase %>.new<%= controller_class_name.downcase.singularize %>'), request.url
    new!
  end

protected
    def begin_of_association_chain
      current_account
    end

    def collection
     @<%= controller_class_name.downcase %> ||= end_of_association_chain.search(params[:search]).order(sort_column + ' ' + sort_direction).paginate(:per_page => 15, :page => params[:page])
    end

  private
    def sort_column
      <%= controller_class_name.camelize.singularize %>.column_names.include?(params[:sort]) ? params[:sort] : "1"
    end

end