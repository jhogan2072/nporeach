class PrivilegesController < InheritedResources::Base
  add_breadcrumb I18n.t('layouts.application.home'), :root_path
  add_breadcrumb I18n.t('privileges.privileges'), :privileges_path
  respond_to :js, :only => :index
  helper_method :sort_column


  def update
    @privilege = Privilege.find(params[:id])
    @privilege.category = Privilege::CONTROLLERS[@privilege.controller][0]
    @privilege.operations = 0
    @checkboxvalues = params[:allowed_operations]
    @checkboxvalues.each do |value|
      @privilege.operations += value.to_i
    end
    update! {privileges_url}
  end

  def create
    @privilege = current_account.privileges.build(params[:privilege])
    @privilege.category = Privilege::CONTROLLERS[@privilege.controller][0]
    @privilege.operations = 0
    @checkboxvalues = params[:allowed_operations]
    @checkboxvalues.each do |value|
      @privilege.operations += value.to_i
    end
    create! {privileges_url}
  end

  def edit
    add_breadcrumb I18n.t('privileges.editprivilege'), request.url
    edit!
  end

  def new
    add_breadcrumb I18n.t('privileges.newprivilege'), request.url
    new!
  end

protected
    def begin_of_association_chain
      current_account
    end

    def collection
     @privileges ||= end_of_association_chain.search(params[:search]).order(sort_column + ' ' + sort_direction).paginate(:per_page => 15, :page => params[:page])
    end

  private
    def sort_column
      Privilege.column_names.include?(params[:sort]) ? params[:sort] : "1"
    end

end
