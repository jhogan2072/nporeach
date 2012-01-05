class RemoveActionFromPrivilege < ActiveRecord::Migration
  def change
    remove_column :privileges, :action
  end
end
