class RefactorPrivileges < ActiveRecord::Migration
  def up
    drop_table :privileges
    rename_column :default_privileges, :operations, :actions
    rename_table :default_privileges, :privileges
    rename_column :default_grants, :default_privilege_id, :privilege_id
  end

  def down
    rename_column :default_grants, :privilege_id, :default_privilege_id
    rename_table :privileges, :default_privileges
    rename_column :default_privileges, :actions, :operations
    create_table :privileges do |t|
      t.string "name"
      t.string "description"
      t.string "controller"
      t.string "menu_text"
      t.integer "account_id"
      t.integer "operations"
      t.string "category"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
