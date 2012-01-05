class RenameDefaultPrivilege < ActiveRecord::Migration
  def up
    rename_column :default_grants, :privilege_id, :default_privilege_id
    rename_column :default_grants, :role_id, :default_role_id
  end

  def down
    rename_column :default_grants, :default_privilege_id, :privilege_id
    rename_column :default_grants, :default_role_id, :role_id
  end
end
