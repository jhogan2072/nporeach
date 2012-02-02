class ColumnPreference < ActiveRecord::Base
  belongs_to :user
  validates :user_id, :presence => true
  validates :collection_name, :presence => true
  validates :column_order, :presence => true
  validates :column_name, :presence => true, :uniqueness => {:scope => [:user_id, :collection_name]}
  default_scope :order => 'column_order'
  scope :included_columns, where(:is_displayed => true)

  def self.user_columns(collection_name, user_id)
    included_columns.where("collection_name = ? and user_id = ?", collection_name, user_id)
  end

  # This is a hash of hashes containing information about the various collections for which columns may be selected
  # The array of fields for each column consists of true/false to include by default, its localized name, the display type for that column
  # in the list - e.g. link, date, string, and an optional type in the case of a link
  AVAILABLE_COLUMNS = {
    "users" => {
      "full_name"=>[true, I18n.t('users.user_list.name'), "link", "edit" ],
      "email"=>[true, I18n.t('users.user_list.email'), "string", "" ],
      "last_name"=>[false, I18n.t('users.user_list.last_name'), "string", "" ],
      "first_name"=>[false, I18n.t('users.user_list.first_name'), "string", "" ],
      "middle_name"=>[false, I18n.t('users.user_list.middle_name'), "string", "" ],
      "address"=>[true, I18n.t('users.user_list.address'), "string", "" ],
      "city"=>[true, I18n.t('users.user_list.city'), "string", "" ],
      "state"=>[true, I18n.t('users.user_list.state'), "string", "" ],
      "zip"=>[true, I18n.t('users.user_list.zip'), "string", "" ],
      "home_phone"=>[true, I18n.t('users.user_list.home_phone'), "string", "" ],
      "work_phone"=>[false, I18n.t('users.user_list.work_phone'), "string", "" ],
      "mobile_phone"=>[false, I18n.t('users.user_list.mobile_phone'), "string", "" ]
      }
    }

end
