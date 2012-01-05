class RolesController < InheritedResources::Base
  add_breadcrumb I18n.t('layouts.application.home'), :root_path
  add_breadcrumb I18n.t('roles.roles'), :roles_path
  respond_to :js, :only => :index
  helper_method :sort_column

  def create
    @privileges = populate_privileges
    create! { roles_url }
  end

  def update
    @privileges = populate_privileges
    update! {roles_url}
  end

  def edit
    add_breadcrumb I18n.t('roles.editrole'), request.url
    @privileges = populate_privileges
    edit!
  end

  def new
    add_breadcrumb I18n.t('roles.newrole'), request.url
    @privileges = populate_privileges
    new!
  end

protected
    def begin_of_association_chain
      current_account
    end

    def collection
     @roles ||= end_of_association_chain.search(params[:search]).order(sort_column + ' ' + sort_direction).paginate(:per_page => 15, :page => params[:page])
    end

    def populate_privileges
      priv_array = []
      if current_account.privileges.all.length > 0
        current_account.privileges.all.each do |priv|
          priv_array << priv
        end
      end
      return priv_array.group_by {|priv| priv.category}
    end

  private
    def sort_column
      Role.column_names.include?(params[:sort]) ? params[:sort] : "1"
    end

end
