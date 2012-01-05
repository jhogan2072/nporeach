class RemoveMenuItemIdFromPrivileges < ActiveRecord::Migration
  def up
    remove_column :privileges, :menu_item_id
    add_column :privileges, :default_action, :string
    add_column :privileges, :menu_text, :string
    add_column :grants, :operations, :integer
    drop_table :privilege_actions
  end

  def down
    add_column :privileges, :menu_item_id, :integer
    remove_column :privileges, :default_action
    remove_column :privileges, :menu_text
    remove_column :grants, :operations
    create_table :privilege_actions do |t|
      t.integer :privilege_id
      t.string :action

      t.timestamps
    end
  end
end
