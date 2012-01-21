class RenameAdminToOwner < ActiveRecord::Migration
  def up
    rename_column :users, :admin, :owner
  end

  def down
    rename_column :users, :owner, :admin
  end
end
