class PrivilegesController < InheritedResources::Base
  add_breadcrumb I18n.t('layouts.application.home'), :root_path
  add_breadcrumb I18n.t('privileges.privileges'), :privileges_path


  def update
    @privilege = Privilege.find(params[:id])
    @privilege.category = Privilege::CONTROLLERS[@privilege.controller][0]
    @privilege.operations = 0
    @checkboxvalues = params[:allowed_operations]
    @checkboxvalues.each do |value|
      @privilege.operations += value.to_i
    end
    update!
  end

  def create
    @privilege = current_account.privileges.build(params[:privilege])
    @privilege.category = Privilege::CONTROLLERS[@privilege.controller][0]
    @privilege.operations = 0
    @checkboxvalues = params[:allowed_operations]
    @checkboxvalues.each do |value|
      @privilege.operations += value.to_i
    end
    create! {privileges_path}
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
end
