class AddCategoryToPrivileges < ActiveRecord::Migration
  def up
    add_column :privileges, :category, :string
    drop_table :menu_items
  end

  def down
    remove_column :privileges, :category
    create_table :menu_items do |t|
      t.string name
      t.timestamps
    end
  end
end
