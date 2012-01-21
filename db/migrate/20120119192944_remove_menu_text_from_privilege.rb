class RemoveMenuTextFromPrivilege < ActiveRecord::Migration
  def up
    remove_column :privileges, :menu_text
  end

  def down
    add_column :privileges, :menu_text, :string
  end
end
