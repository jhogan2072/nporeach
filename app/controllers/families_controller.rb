class FamiliesController < InheritedResources::Base
  respond_to :html, :json
  respond_to :js, :only => [:index, :message]
  respond_to :csv, :only => :my_family
  before_filter :create_primary_contact, :only => [:new]
  layout :resolve_layout

  add_breadcrumb I18n.t('layouts.application.home'), :root_path
  add_breadcrumb I18n.t('families.families'), :families_path, :if => :have_access?

  def create
    #@spw = Devise.friendly_token.first(8)
    @family = Family.new
    @family.is_individual = params[:family][:is_individual]
    @family.mailing_greeting = params[:family][:mailing_greeting]
    @family.name = params[:family][:name]
    @family.account_id = current_account.id
    @family.primary_contact = User.new
    populate_primary_contact(@family.primary_contact)

    create! { families_url }
  end

  def update
    update! { families_url }
  end

  def members
    @family = Family.find(params[:id])
    add_breadcrumb @family.name + " " + I18n.t('families.members.familymembers'), request.url
    @selected_columns = Array.new(["full_name","email", "designations"])
    @users = User.where("family_id = ?", params[:id]).paginate(:per_page => 15, :page => params[:page])
  end

  def my_family
    add_breadcrumb I18n.t('families.myfamily'), request.url
    @family = current_user.family
    @selected_columns = Array.new(["full_name","email", "designations"])
    @users = User.where("family_id = ?", current_user.family.id).paginate(:per_page => 15, :page => params[:page])
    respond_to do |format|
      format.html
      format.csv do
        @exported_users = @users
        export_csv(@selected_columns, @exported_users, "users")
      end
    end
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
    # @family = current_account.families.build(params[:family])
    # in the new/create actions and
    # @family = current_account.families.find(params[:id]) in the
    # edit/show/destroy actions.
    def begin_of_association_chain
      current_account
    end

    def create_primary_contact
      build_resource.primary_contact = User.new unless build_resource.primary_contact
    end

    def populate_primary_contact(primary_contact_user)
      primary_contact_user.account_id = current_account.id
      primary_contact_user.first_name = params[:family][:primary_contact_attributes][:first_name]
      primary_contact_user.last_name = params[:family][:primary_contact_attributes][:last_name]
      primary_contact_user.middle_name = params[:family][:primary_contact_attributes][:middle_name]
      primary_contact_user.address = params[:family][:primary_contact_attributes][:address]
      primary_contact_user.city = params[:family][:primary_contact_attributes][:city]
      primary_contact_user.state = params[:family][:primary_contact_attributes][:state]
      primary_contact_user.zip = params[:family][:primary_contact_attributes][:zip]
      primary_contact_user.home_phone = params[:family][:primary_contact_attributes][:home_phone]
      primary_contact_user.mobile_phone = params[:family][:primary_contact_attributes][:mobile_phone]
      primary_contact_user.work_phone = params[:family][:primary_contact_attributes][:work_phone]
      primary_contact_user.is_primary_contact = true
      #build_resource.primary_contact = User.new unless build_resource.primary_contact
    end

    def collection
     @families ||= end_of_association_chain.search(params[:search]).order(sort_column + ' ' + sort_direction).paginate(:per_page => 15, :page => params[:page])
    end
private
  def have_access?
    current_user.can?("families", "index")
  end

  def help_text
    I18n.t('families.menu.info') + "_001"
  end

  def resolve_layout
    case action_name
      when 'my_family'
        'application'
      else
        'two_column'
    end
  end

end
