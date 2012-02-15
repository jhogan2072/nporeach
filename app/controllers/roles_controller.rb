class RolesController < InheritedResources::Base
  add_breadcrumb I18n.t('layouts.application.home'), :root_path
  add_breadcrumb I18n.t('roles.roles'), :roles_path
  respond_to :js, :only => :index

  def create
    @privileges = Privilege.privileges_by_category
    create! { roles_url }
  end

  def update
    @privileges = Privilege.privileges_by_category
    update! {roles_url}
  end

  def edit
    add_breadcrumb I18n.t('roles.editrole'), request.url
    @privileges = Privilege.privileges_by_category
    edit!
  end

  def new
    add_breadcrumb I18n.t('roles.newrole'), request.url
    @privileges = Privilege.privileges_by_category
    new!
  end

protected
    def begin_of_association_chain
      current_account
    end

    def collection
     @roles ||= end_of_association_chain.search(params[:search]).order(sort_column + ' ' + sort_direction).paginate(:per_page => 15, :page => params[:page])
    end

end
