class FamiliesController < InheritedResources::Base
  respond_to :html, :json
  respond_to :js, :csv, :only => [:index, :message]
  before_filter :build_primary_contact, :only => [:new, :create]
  layout 'two_column'

  add_breadcrumb I18n.t('layouts.application.home'), :root_path
  add_breadcrumb I18n.t('families.families'), :families_path

  def create
    #@spw = Devise.friendly_token.first(8)
    @family = Family.new(params[:family])
    @family.primary_contact.account_id = current_account.id
    @family.account_id = current_account.id
    create! { families_url }
  end

  def update
    update! { families_url }
  end

  def members
    @family = Family.find(params[:id])
    add_breadcrumb @family.name + " " + I18n.t('families.members.familymembers'), request.url
    # @selected_columns = get_selected_columns('users')
    @selected_columns = Array.new(["full_name","email", "designations"])
    @users = User.where("family_id = ?", params[:id]).paginate(:per_page => 15, :page => params[:page])
  end
  
  def edit
    add_breadcrumb I18n.t('families.editfamily'), request.url
    edit!
  end

  def new
    #@spw = Devise.friendly_token.first(8)
    add_breadcrumb I18n.t('families.newfamily'), request.url
    new!
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

    def build_primary_contact
      build_resource.primary_contact = User.new unless build_resource.primary_contact
    end

    def collection
     @families ||= end_of_association_chain.search(params[:search]).order(sort_column + ' ' + sort_direction).paginate(:per_page => 15, :page => params[:page])
    end
private
  def left_menu
    menu_array = Array.new
    menu_array << [t('families.menu.importfamilies'), url_for(csv_import_path(:data => "students"))]
    menu_array << [t('families.menu.viewfamilies'), url_for(families_path)]
    menu_array << [t('families.menu.managesystemusers'), url_for(users_path)]
  end

end